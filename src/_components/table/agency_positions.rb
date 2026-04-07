# frozen_string_literal: true

module Table
  # The positions at the top of an agency page
  class AgencyPositions < Bridgetown::Component
    def initialize(agency:)
      super()
      @agency = agency
    end

    def grouped_positions
      all_positions = @agency.all_positions_and_details_out
      grouped_positions = all_positions.group_by(&:sort_name)
      # internal sort for each grouping
      grouped_positions.each_value { |positions| positions.sort_by!(&:sort_date) }

      # return each grouping
      grouped_positions.values.sort_by { |positions| [positions[0].sort_date, positions[0].sort_name] }
    end

    def template
      html lambda {
        <<~HTML
            <table class="my-table-style">
              <thead>
                <tr>
                  <th class="text-left my-2col-table-col1">Name</th>
                  <th class="text-left my-2col-table-col2">Positions</th>
                </tr>
              </thead>
              <tbody>
                 #{ html_map(grouped_positions) do |positions|
                   render AgencyPositionRow.new(positions: positions, agency: @agency)
                 end
                 }
              </tbody>
          </table>
        HTML
      }
    end
  end
end
