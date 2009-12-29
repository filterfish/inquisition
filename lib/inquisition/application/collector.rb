require File.dirname(__FILE__) + '/../../inquisition'

require 'socket'

class Collector

  include Inquisition

  def initialize

    @opts = Trollop::options do
      opt :daemon, "Daemonise", :default => false
      opt :pid, "Create PID file", :default => false
    end

    @config = Configuration.new

    @period = @config.system[:frequency]

    Inquisition::Logging.init(@config.system[:log_config], 'collector')

    @checks = Checks.new(@config)
    Inquisition::Logging.info("Load external checks")
    @checks.load_checks('external_checks')

    Inquisition::Logging.info("Installing signal handlers")

    # Reload the config when we get a SIGHUP
    trap :HUP, lambda {
      Inquisition::Logging.info("Reloading config"); @config.reload!
      if @timer && EventMachine.reactor_running?
        @timer.cancel
        @timer = EventMachine::PeriodicTimer.new(@config.system[:frequency]) {
          run_checks
        }
      else
        Inquisition::Logging.error("Cannot reload config, reactor not running")
      end
    }

    ["SIGTERM", "SIGINT", "SIGKILL"].each do |sig|
      trap sig, lambda { puts "\nexiting"; exit }
    end

    Daemonize.daemonize('/var/log/inquisition/console-daemon.log') if @opts[:daemon]

    Daemons::PidFile.new('/var/run/inquistion', File.basename($0)).pid = Process.pid if @opts[:pid]
  end

  def run
    AMQP.start(:host => 'localhost') do
      @mq = MQ.new
      @timer = EventMachine::PeriodicTimer.new(@config.system[:frequency]) {
        run_checks
      }
    end
  end

  private

  def run_checks
    @checks.run_checks do |result,command,target,limits|
      @mq.topic('data').publish(Marshal.dump([command, target, result, limits]), :key => Socket.gethostname)
    end
  end
end
