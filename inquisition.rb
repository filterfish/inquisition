#!/usr/bin/env ruby

require 'rubygems'
require 'logging'
require 'pp'

require 'lib/inquisition/config'
require 'lib/inquisition/checks'

include Inquisition

logger = Logging.logger(STDOUT)

config = Configuration.new

checks = Checks.new
checks.load_checks('external_checks')

external_checks = ExternalChecks.new

config.run_checks do |check, target|
  logger.info("  #{external_checks.checks[check].call(target)}")
end
