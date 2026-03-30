# frozen_string_literal: true

module MonthGrid
  # Represents an event in the MonthGrid
  class Event < Bridgetown::Component
    def initialize(event:)
      super()
      @event = event
    end
  end
end
