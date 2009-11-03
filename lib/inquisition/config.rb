require 'trollop'
require 'yaml'
require 'erb'

module Inquisition
  attr_accessor :checks_file

  class Configuration

    def initialize(options={})

      @opts = Trollop::options do
        opt :config, "Config file.", :default => "/etc/inquisition/config.yaml"
        opt :checks, "Checks file.", :default => File.join(File.dirname(__FILE__), 'external_checks.rb')
      end
      parse_config
    end

    def checks
      @config['checks']
    end

    def subsystems
      checks.keys
    end

    def alerts
      @config['alerts']
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
