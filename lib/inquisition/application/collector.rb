require File.dirname(__FILE__) + '/../../inquisition'

require 'socket'

class Collector

  include Inquisition

  def initialize

    @opts = Trollop::options do
      opt :daemon, "Daemonise", :default => false
    end

    @config = Configuration.new

    @period = @config.system[:frequency]

    Inquisition::Logging.init(@config.system[:log_config], 'collector')

    @checks = Checks.new(@config)
    Inquisition::Logging.info("Load external checks")
    @checks.load_checks('external_checks')

    Inquisition::Logging.info("Installing signal handlers")

    # Reload the config when we get a SIGHUP
    trap :HUP, lambda { Inquisition::Logging.info("Reloading config"); @config.reload! }

    ["SIGTERM", "SIGINT", "SIGKILL"].each do |sig|
      trap sig, lambda { puts "\nexiting"; exit }
    end

    Daemonize.daemonize('/var/log/inquisition/console-daemon.log') if @opts[:daemon]
  end

  def run
    AMQP.start(:host => 'localhost') do
      mq = MQ.new
      EM.add_periodic_timer(@config.system[:frequency]) {
        @checks.run_checks do |result,command,target,limits|
          mq.topic('data').publish(Marshal.dump([command, target, result, limits]), :key => Socket.gethostname)
        end
      }
    end
  end
end
