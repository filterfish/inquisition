module Inquisition
  class Limits
    def initialize(todo)
      @todo = todo
    end

    def check(value, limits)

      return if limits.empty?

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
