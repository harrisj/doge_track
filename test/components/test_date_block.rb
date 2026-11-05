# frozen_string_literal: true

require 'edtf'
require_relative '../minitest_helper'
require_relative '../../src/_components/grid/date_block'

class TestDateBlock < Bridgetown::Test
  describe 'sorting' do
    def block_for(date)
      ::Grid::DateBlock.new(date: ::EDTF.parse(date))
    end

    it 'resolves an interval with an open bound to the known end date' do
      expect(block_for('../2025-12-31').sort_date_value).must_equal Date.new(2025, 12, 31)
    end

    it 'uses the end of the range when both interval bounds are known' do
      expect(block_for('2025-01-20/2025-12-31').sort_date_value).must_equal Date.new(2025, 12, 31)
    end

    it 'falls back to the start bound when the interval end is open' do
      expect(block_for('2025-01-20/').sort_date_value).must_equal Date.new(2025, 1, 20)
    end

    it 'sorts a mixed list of date blocks without raising' do
      sorted = [block_for('../2025-12-31'), block_for('2025-01-20/'), block_for('2025-03-05')].sort

      expect(sorted.map { |block| block.sort_date_value.to_s }).must_equal %w[2025-01-20 2025-03-05 2025-12-31]
    end

    it 'compares undated date blocks without raising' do
      expect(block_for(nil) <=> block_for('2025-03-05')).must_equal(-1)
      expect(block_for('2025-03-05') <=> block_for(nil)).must_equal 1
    end
  end
end
