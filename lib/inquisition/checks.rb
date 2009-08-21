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
      path = (File.symlink?(dev)) ? Pathname.new(dev).realpath.to_s : dev
      @ohai[:filesystem][path]
    end
  end
end
