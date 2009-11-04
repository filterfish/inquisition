module Inquisition

  class BooleanLimit
    def initialize(value, limits)
      @limit = limits[0].to_s
      @value = value.to_s
    end

    def check
      if @limit == @value
        yield
      end
    end
  end

  class NumberLimit
    def initialize(value, limits)
      @value = value.to_f

      @upper = (limits[0]) ? Convertor.parse(limits[0]) : 0
      @lower = (limits[1]) ? Convertor.parse(limits[1]) : 0
    end

    def check
      if @value > @upper
        Inquisition::Logging.debug("value [#{@value}] > limit [#{@upper}]")
        yield
      elsif @lower && @value < @lower
        Inquisition::Logging.debug("value [#{@value}] < limit [#{@lower}]")
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
      when value == -1
        return -1
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
