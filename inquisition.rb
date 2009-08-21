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

config.checks.each do |subsystem_name, subsystem_config|
  subsystem_config.each do |check|
    check_name = check.keys.first
    config = check[check_name]
    config[1..-1].each do |check|
      final_check = "#{subsystem_name}_#{check}".to_sym
      logger.info("Checking #{subsystem_name}/#{check_name}/#{final_check}")
      logger.info("  #{external_checks.checks[final_check].call(config[0])}")
    end
  end
end
