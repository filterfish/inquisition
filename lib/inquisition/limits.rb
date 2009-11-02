module Inquisition

  class BooleanLimit
    def initialize(value, limits)
      @limit = limits[0].to_s
      @value = value
    end

    def check
      if @limits == @value
        yield
      end
    end
  end

  class NumberLimit
    def initialize(value, limits)
      @logger = Logging.logger(STDOUT)
      @logger.level = :debug
      @value = value.to_f

      @upper = (limits[0]) ? Convertor.parse(limits[0]) : 0
      @lower = (limits[1]) ? Convertor.parse(limits[1]) : 0
    end

    def check
      if @value > @upper
        @logger.debug("value [#{@value}] > limit [#{@upper}]")
        yield
      elsif @lower && @value < @lower
        @logger.debug("value [#{@value}] < limit [#{@lower}]")
        yield
      end
    end
  end

  class Limits
    def initialize(todo)
      @todo = todo
    end

    def check(value, limits)
      case
      # Alert is boolean
      when limits.empty?
        return
      when value.is_a?(TrueClass) || value.is_a?(FalseClass)
        checker = BooleanLimit.new(value, limits)
      else
        checker = NumberLimit.new(value, limits)
      end
      checker.check { @todo.call }
    end
  end
end
