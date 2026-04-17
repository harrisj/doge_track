# frozen_string_literal: true

module Table
  # A single row in the agency positions table
  class AgencyPositionRow < Bridgetown::Component
    def initialize(positions:, agency:)
      super()
      @positions = positions
      @agency = agency
      @sources = positions.map(&:sources).flatten.compact.uniq.sort_by(&:sort_date)

      @person = positions[0].person
      @doge_alias = positions[0].doge_alias

      @start_date = positions[0].start_date
      agency_positions = positions.filter { |pos| pos.agency_id == agency.id }.sort_by(&:sort_date)

      if agency_positions&.last&.end_date
        @last_position = agency_positions.last
        @end_date = @last_position.end_date
      elsif @person&.govt_exit_date
        @end_date = @person.govt_exit_date
      end
    end
  end
end
