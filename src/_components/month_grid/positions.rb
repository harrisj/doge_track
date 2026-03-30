# frozen_string_literal: true

module MonthGrid
  # Represents a collection of positions
  class Positions < Bridgetown::Component
    def initialize(positions:)
      super()
      @positions = positions
    end
  end
end
