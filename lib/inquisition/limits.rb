module Inquisition
  class Limits
    def initialize(todo)
      @todo = todo
    end

    def check(value, limits)

      case
      # Alert is boolean
      when value.is_a?(TrueClass) || value.is_a?(FalseClass)
        if limits[0].to_s == value
          @todo.call
        end
        return
      when limits.empty?
        return

      else
        value = value.to_f
        upper = limits[0].to_f
        lower = limits[1].to_f

        if value > upper
          @todo.call
        elsif lower && value < lower
          @todo.call
        end
      end
    end
  end
end
