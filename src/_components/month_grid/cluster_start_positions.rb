# frozen_string_literal: true

module MonthGrid
  # A representation of the start positions
  class ClusterStartPositions < Bridgetown::Component
    def initialize(positions:)
      super()
      @positions = positions
    end

    def starts_section
      by_agency = @positions.select do |pos|
        %w[appointed consultant detailed].include?(pos.type) && pos.person
      end.group_by(&:agency_id)
      return unless by_agency.any?

      html_map(by_agency) do |grp|
        agency_id, positions = grp
        render GroupedAgencyPositions.new(agency_id: agency_id, positions: positions)
      end
    end

    def converts_section
      positions = @positions.select { |pos| pos.type == 'converted' }

      html_map(positions) do |pos|
        render SinglePosition.new(position: pos)
      end
    end

    def promotions_section
      positions = @positions.select { |pos| pos.type == 'promotion' }

      html_map(positions) do |pos|
        render SinglePosition.new(position: pos)
      end
    end

    def demotions_section
      positions = @positions.select { |pos| pos.type == 'demotion' }

      html_map(positions) do |pos|
        render SinglePosition.new(position: pos)
      end
    end

    def template
      html lambda {
        <<~HTML
          #{html -> { starts_section }}
          #{html -> { converts_section }}
          #{html -> { promotions_section }}
          #{html -> { demotions_section }}
        HTML
      }
    end
  end
end
