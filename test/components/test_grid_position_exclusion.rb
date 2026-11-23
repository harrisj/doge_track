# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/grid/extra_mixins'
require_relative '../../src/_components/grid/month'
require_relative '../../src/_components/grid/person_positions_agency'
require_relative '../../src/_components/grid/cluster_start_positions'

# Internal transfers (type == 'internal') represent intra-agency moves that are
# excluded from the positions grid. These tests assert that every component
# which renders positions applies that same exclusion, so an internal transfer
# can never produce an orphaned empty date block.
class TestGridPositionExclusion < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  def internal_transfer
    ::Position.find(id: 'internal-hhs-fema-edward-coristine')
  end

  describe 'internal transfer exclusion' do
    it 'excludes internal transfers from PersonPositionsAgency' do
      person = ::Person['Edward Coristine']
      positions = person.positions

      rejected = Grid::PersonPositionsAgency.new(
        agency: positions.first.agency,
        person: person,
        positions: positions
      )

      refute_includes rejected.instance_variable_get(:@positions).map(&:id),
                      'internal-hhs-fema-edward-coristine'
    end

    it 'excludes internal transfers from ClusterStartPositions' do
      # ClusterStartPositions renders nothing for internal transfers: each
      # section selects a specific type, so an internal position falls through
      # every branch. Assert that the rendered template contains no markup.
      positions = [internal_transfer]
      cluster = Grid::ClusterStartPositions.new(positions: positions)

      rendered = render_component(cluster)

      assert_empty rendered.strip
    end

    it 'excludes internal transfers from the Month grid start_date' do
      # Find a month where the ONLY starting position is the internal transfer.
      month = Grid::Month.new(year: 2025, month: 2)

      internal_start = internal_transfer.start_date
      internal_start = internal_start.to_date if internal_start.respond_to?(:to_date)

      # The internal transfer starts 2025-02-05; the month view must not add it
      # as a start position (it is skipped like the other grids). The day block
      # is pre-populated for every day of the month, so we inspect its
      # @start_positions array rather than the day-key presence.
      block = month.instance_variable_get(:@days)[internal_start]

      refute_includes block.instance_variable_get(:@start_positions).map(&:id),
                      'internal-hhs-fema-edward-coristine'
    end
  end
end
