require 'trollop'
require 'yaml'
require 'erb'

module Inquisition
  attr_accessor :checks_file

  class Configuration

    def initialize(options={})
      @logger = (options[:logger]) ? options[:logger] : Logging.logger(STDOUT)
      @logger.level = :info

      @opts = Trollop::options do
        opt :config, "Config file.", :default => "/etc/inquisition/config.yaml"
        opt :checks, "Checks file.", :default => File.join(File.dirname(__FILE__), 'external_checks.rb')
      end
      parse_config
    end

    def checks
      @config['checks']
    end

    def run_checks
      checks.each do |subsystem_name, subsystem_config|
        subsystem_config.each do |check|
          check_name = check.keys.first
          config = check[check_name]
          config[1..-1].each do |check|
            check = check.split
            command = "#{subsystem_name}/#{check.first.to_sym}"
            limits = check[1..-1]
            @logger.debug("Checking #{check_name}/#{command}")
            yield command, config[0], limits
          end
        end
      end
    end

    def reload!
      parse_config
    end

    private

    def parse_config
      @config = YAML.load(ERB.new(IO.read(@opts[:config])).result)
    end
  end
end
