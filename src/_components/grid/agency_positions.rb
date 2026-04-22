# frozen_string_literal: true

module Grid
  # A positions panel in an agency
  class AgencyPositions < Bridgetown::Component
    def initialize(agency:)
      super()
      @agency = agency

      all_positions = @agency.all_positions_and_details_out
      @grouped_positions = all_positions.group_by(&:sort_name)
      # internal sort for each grouping
      @grouped_positions.each_value { |positions| positions.sort_by!(&:sort_date) }
    end

    def each_person
      # return each grouping
      sorted = @grouped_positions.values.sort_by { |positions| [positions[0].sort_date, positions[0].sort_name] }
      sorted.each do |positions|
        person = positions.first.person || positions.first.doge_alias
        next if person.nil?

        yield [person, positions]
      end
    end
  end
end
