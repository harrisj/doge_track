# frozen_string_literal: true

module MonthGrid
  # Represents a single date in the MonthGrid
  class DateRow < Bridgetown::Component
    def initialize(date:)
      super()
      @date = date

      @events = []
      @start_positions = []
      @end_positions = []
      @system_grants = []
      @system_revokes = []
      @executive_orders = []
    end

    attr_reader :date

    def any?
      @events.any? || @start_positions.any? || @end_positions.any? || @system_grants.any? \
      || @system_revokes.any? || @executive_orders.any?
    end

    def add_event(event)
      @events << event
    end

    def add_start_position(position)
      @start_positions << position
    end

    def add_end_position(position)
      @end_positions << position
    end

    def add_system_grant(system_role)
      @system_grants << system_role
    end

    def add_system_revoke(system_role)
      @system_revokes << system_role
    end

    def add_executive_order(order)
      @executive_orders << order
    end
  end
end
