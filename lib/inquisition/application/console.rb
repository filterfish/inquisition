require File.dirname(__FILE__) + '/../../inquisition'

class Console

  include Inquisition

  def initialize
    ["TERM", "INT", "QUIT"].each do |sig|
        trap sig, lambda { Inquisition::Logging.info("exiting"); exit }
    end

    @opts = Trollop::options do
      opt :xmpp, "Don't send xmpp messages", :default => true
      opt :daemon, "Daemonise", :default => false
      opt :pid, "Create PID file", :default => false
    end

    @config = Configuration.new

    Daemonize.daemonize('/var/log/inquisition/console-daemon.log') if @opts[:daemon]

    Daemons::PidFile.new('/var/run/inquistion', File.basename($0)).pid = Process.pid if @opts[:pid]

    Inquisition::Logging.init(@config.system[:log_config], 'console')

    if @opts[:xmpp]
      Inquisition::Logging.debug("Connecting to the XMPP server")
      @xmpp = Alerts::XMPP.new(@config.alerts['xmpp'])
      Inquisition::Logging.info("Connected to the XMPP server")
    end
  end

  def run
    AMQP.start(:host => 'localhost') {

      mq = MQ.new
      data_queue = mq.queue('data').bind(mq.topic('data'), :key => '*')

      data_queue.subscribe do |h, message|
        m = Marshal.restore(message)
        Inquisition::Logging.value("%s: %s, %s, %s, %s" % [h.routing_key, m[0], m[1].inspect, m[2], m[3].inspect])
        todo = lambda { @xmpp.send("Problem: #{m.inspect}") if @opts[:xmpp]; Inquisition::Logging.alert("#{m.inspect}") }
        limit = Limits.new(todo)
        if limit.check(m[2], m[3]) == -1
          todo.call
          Inquisition::Logging.error("Check returned -1")
        end
      end
    }
  end
end
