require 'ohai'
require 'pathname'

module Inquisition

  class Checks

    PAGE_SIZE = 4096

    def initialize(config, options={})
      @logger = (options[:logger]) ? options[:logger] : Logging.logger(STDOUT)

      @config = config
      @ohai = Ohai::System.new
      @ohai.require_plugin('os')
    end

    def file_system(ohai, dev)
      path = (File.symlink?(dev)) ? Pathname.new(dev).realpath.to_s : dev
      ohai[:filesystem][path]
    end

    def load_checks(file)
      path = File.join(File.dirname(__FILE__), "#{file}.rb")
      @checks = self.instance_eval(IO.read(path), path, 1)
    end

    def run_checks
      load_plugins
      @config.checks.each do |subsystem_name, subsystem_config|
        subsystem_config.each do |check|
          check_name = check.keys.first
          config = check[check_name]
          config[1..-1].each do |check|
            check = check.split
            command = "#{subsystem_name}/#{check.first.to_sym}"
            limits = check[1..-1]
            @logger.debug("Checking #{check_name}/#{command}")
            result = @checks[command].call(@ohai, config[0])
            yield result, command, config[0], limits
          end
        end
      end
    end

    private

    # Load the list of plugins. This is badly misnamed but it
    # corresponds with ohai terminology
    def load_plugins
      plugins(@config.subsystems).each do |plugin|
        @ohai.require_plugin(plugin, true)
      end
    end

    # Return the list of plugins to load
    def plugins(subsystems)
      subsystem_regex = Regexp.new(subsystems.join('\b|\b').gsub(/^/, '\b').gsub(/$/, '\b'))

      plugins = Ohai::Config[:plugin_path].inject([]) do |plugins,path|
        file_regex = Regexp.new("#{path}#{File::SEPARATOR}(.+).rb$")
        paths = [Dir[File.join(path, '*')], Dir[File.join(path, @ohai[:os], '**', '*')]].flatten
        plugins << paths.inject([]) do |acc,path|
          md = file_regex.match(path)
          acc << md[1] if md
          acc
        end
      end.flatten

      plugins.select { |p| subsystem_regex.match(p) }
    end
  end
end
