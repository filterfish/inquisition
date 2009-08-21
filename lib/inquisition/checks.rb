require 'ohai'
require 'pathname'

module Inquisition

  class Checks

    def initialize
      @ohai = Ohai::System.new
      @ohai.all_plugins
    end

    def load_checks(file)
      load File.join(File.dirname(__FILE__), "#{file}.rb")
    end

    def file_system(dev)
      @ohai[:filesystem][Pathname.new(dev).realpath.to_s]
    end
  end
end
