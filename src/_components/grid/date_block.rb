# frozen_string_literal: true

module Grid
  # Represents a single date in the MonthGrid
  class DateBlock < Bridgetown::Component
    include Comparable

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

    def <=>(other)
      self_date = date
      other_date = other.date

      if self_date.year != other_date.year
        self_date.year <=> other_date.year
      elsif self_date.month != other_date.month
        self_date.month <=> other_date.month
      elsif self_date.unspecified?(:day) && other_date.unspecified?(:day)
        0
      elsif self_date.unspecified?(:day)
        1
      elsif other_date.unspecified?(:day)
        -1
      else
        self_date.day <=> other_date.day
      end
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
