# frozen_string_literal: true

require 'edtf'

# Helper for representing a combined of all Month stuff
module Grid
  # Main class
  class Focused < Bridgetown::Component
    attr_reader :undated

    def initialize(agency: nil, person: nil, project: nil)
      super()
      @agency = agency
      @person = person
      @project = project

      raise ArgumentError, 'You must provide an agency_id, name or project' unless @agency || @person || @project

      @days = {}

      initialize_days
    end

    def each_date(&)
      @days.values.sort.each(&)
    end

    def get_date(date)
      date = Date.edtf(date) if date.is_a? String
      key = date.edtf

      @days[key] = DateBlock.new(date: date) if @days[key].nil?

      @days[key]
    end

    def initialize_days
      if @agency
        events = @agency.all_events
        positions = @agency.all_positions_and_details_out
        system_roles = @agency.all_systems.map(&:system_roles).flatten
      elsif @person
        events = @person.all_events
        positions = @person.positions
        system_roles = @person.system_roles
      elsif @project
        events = @project.events
        positions = @project.positions
        system_roles = @project.govt_systems.map(&:system_roles).flatten
      else
        raise "This shouldn't happen"
      end

      initialize_events(events)
      initialize_positions(positions)
      initialize_system_roles(system_roles)
    end

    def initialize_events(events)
      events.each do |event|
        next if %w[onboard offboard directory].include?(event.type)

        get_date(event.date).add_event(event)
      end
    end

    def initialize_positions(positions)
      positions.each do |pos|
        get_date(pos.start_date).add_start_position(pos) if pos.start_date
        get_date(pos.end_date).add_end_position(pos) if pos.end_date && pos.end_type != 'replaced'
      end
    end

    def initialize_system_roles(system_roles)
      system_roles.each do |role|
        get_date(role.date_granted).add_system_grant(role) if role.date_granted
        get_date(role.date_revoked).add_system_revoke(role) if role.date_revoked
      end
    end
  end
end
