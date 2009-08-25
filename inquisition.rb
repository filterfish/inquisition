#!/usr/bin/env ruby

require 'rubygems'
require 'logging'
require 'socket'
require 'mq'
require 'pp'

require 'lib/inquisition/config'
require 'lib/inquisition/checks'

include Inquisition

logger = Logging.logger(STDOUT)

config = Configuration.new

signal_handler = lambda { logger.info("Reloading config"); config.reload! }
trap :HUP, signal_handler

checks = Checks.new
checks.load_checks('external_checks')

external_checks = ExternalChecks.new

logger.info("Load external checks")

require 'mq'

AMQP.start(:host => 'localhost') do
  mq = MQ.new
  EM.add_periodic_timer(10) {
    config.run_checks do |command, target, limits|
      result = external_checks.checks[command].call(target)
      mq.topic('data').publish(Marshal.dump([command, target, result, limits]), :key => Socket.gethostname)
    end
  }
end
