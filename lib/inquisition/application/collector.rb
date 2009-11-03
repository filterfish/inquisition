#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../inquisition'

require 'socket'

class Collector

  include Inquisition

  def initialize
    @config = Configuration.new

    @checks = Checks.new(@config)
    Inquisition::Logging.debug("Load external checks")
    @checks.load_checks('external_checks')

    Inquisition::Logging.debug("Installing signal handler")

    # Reload the config when we get a SIGHUP
    trap :HUP, lambda { Inquisition::Logging.info("Reloading config"); @config.reload! }

    ["SIGTERM", "SIGINT", "SIGKILL"].each do |sig|
      trap sig, lambda { puts "\nexiting"; exit }
    end
  end

  def run
    AMQP.start(:host => 'localhost') do
      mq = MQ.new
      EM.add_periodic_timer(1) {
        @checks.run_checks do |result,command,target,limits|
          mq.topic('data').publish(Marshal.dump([command, target, result, limits]), :key => Socket.gethostname)
        end
      }
    end
  end
end
