require 'logging'

module Inquisition
  module Mixin
    module Logging

      @logger = nil

      attr_writer :logger

      def logger
        init
      end

      def init(*opts)
        if @logger.nil?
          @logger = (opts.empty? ? ::Logging.logger(STDOUT) : ::Logging.logger(*opts))
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
