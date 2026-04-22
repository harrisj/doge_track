# frozen_string_literal: true

module Grid
  # A positions panel in an agency
  class PersonPositions < Bridgetown::Component
    def initialize(person:)
      super()
      @person = person

      all_positions = @person.positions
      @grouped_positions = all_positions.group_by(&:sort_parent_agency)
      @grouped_positions.each_value { |positions| positions.sort_by!(&:sort_date) }
    end

    def each_agency
      sorted = @grouped_positions.values.sort_by do |positions|
        [positions[0].sort_date, positions[0].agency_id]
      end

      sorted.each do |positions|
        yield [positions.first.agency, positions]
      end
    end
  end
end
