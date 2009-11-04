require 'logging'

module Inquisition
  module Mixin
    module Logging

      @logger = nil

      attr_writer :logger

      def logger
        init
      end

      def init(log_config=nil, name=nil)
        if @logger.nil?
          @logger = if log_config
                      ::Logging.configure(log_config)
                      ::Logging::Logger[name]
                    else
                      ::Logging.logger(STDOUT)
                    end
        end
        @logger
      end

      def method_missing(method_symbol, *args)
        logger.send(method_symbol, *args)
      end
    end
  end

  class Logging
    extend Mixin::Logging
  end
end
