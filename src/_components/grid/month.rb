# frozen_string_literal: true

require 'edtf'

# Helper for representing a combined of all Month stuff
module Grid
  # Main class
  class Month < Bridgetown::Component
    attr_reader :first_date, :last_date, :undated

    def initialize(year:, month:, agency_id: nil)
      super()
      @year = year
      @month = month
      @agency_id = agency_id

      @first_date = Date.new(@year, @month, 1)
      @last_date = Date.new(@year, @month, -1)

      day_unknown = Date.new(@year, @month, 1).unspecified!(:month)
      @undated = DateBlock.new(date: day_unknown)

      @days = {}
      (@first_date..@last_date).each do |date|
        @days[date] = DateBlock.new(date: date)
      end

      initialize_events
      initialize_positions
      initialize_system_roles
      initialize_exec_orders
    end

    def each_date
      (first_date..last_date).each do |date|
        yield get_date(date)
      end
    end

    def get_date(date)
      date = Date.edtf(date) if date.is_a? String

      if date.unspecified? :day
        @undated
      else
        @days[date]
      end
    end

    def initialize_events
      events = ::Event.for_year_month(@year, @month)

      events.each do |event|
        next if %w[onboard offboard directory].include?(event.type)

        get_date(event.date).add_event(event)
      end
    end

    def initialize_positions
      positions = Position.start_in_year_month(@year, @month)
      positions.each do |pos|
        get_date(pos.start_date).add_start_position(pos)
      end

      positions = Position.end_in_year_month(@year, @month)
      positions.each do |pos|
        next if pos.end_type == 'replaced' || pos.type == 'internal'

        get_date(pos.end_date).add_end_position(pos)
      end
    end

    def initialize_system_roles
      roles = SystemRole.granted_in_year_month(@year, @month)
      roles.each do |role|
        get_date(role.date_granted).add_system_grant(role)
      end

      roles = SystemRole.revoked_in_year_month(@year, @month)
      roles.each do |role|
        get_date(role.date_revoked).add_system_revoke(role)
      end
    end

    def initialize_exec_orders
      orders = ::ExecutiveOrder.in_year_month(@year, @month)
      orders.each do |order|
        get_date(order.date).add_executive_order(order)
      end
    end
  end
end
