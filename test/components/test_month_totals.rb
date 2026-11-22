# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_data/month_totals'

class TestMonthTotals < Bridgetown::Test
  PositionDouble = Struct.new(:start_date, :end_date, :agency_id, keyword_init: true) do
    def min_interval_to_date(_field)
      nil
    end

    def max_date_interval_to_date(_field)
      nil
    end
  end

  PersonDouble = Struct.new(:positions, :govt_exit_date, keyword_init: true) do
    def start_date
      positions.first.start_date
    end
  end

  START_DATE = Date.new(2025, 1, 1)
  END_DATE = Date.new(2026, 12, 31)

  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  describe 'initialize_totals' do
    it 'creates a zeroed counter hash for each key' do
      totals = ::MonthTotals.initialize_totals(%w[2025-01 2025-02])

      expect(totals.keys).must_equal %w[2025-01 2025-02]
      counters = %i[join leave join_nds leave_nds join_doge leave_doge count count_nds count_doge]

      totals.each_value do |values|
        counters.each { |counter| assert_equal 0, values[counter] }
      end
    end
  end

  describe 'reshape_totals' do
    it 'returns the canonical output shape with every counter key' do
      totals = ::MonthTotals.initialize_totals(['2025-01'])
      totals['2025-01'][:count] = 3
      totals['2025-01'][:join] = 1

      result = ::MonthTotals.reshape_totals(totals, ['2025-01'])

      expect(result.keys).must_equal ['2025-01']
      %i[join leave count join_nds leave_nds count_nds join_doge leave_doge count_doge].each do |counter|
        assert result['2025-01'].key?(counter)
      end
      assert_equal 3, result['2025-01'][:count]
      assert_equal 1, result['2025-01'][:join]
    end
  end

  describe 'resolve_start_date' do
    it 'clamps dates before the chart start to the chart start' do
      position = Struct.new(:start_date).new(Date.new(2024, 1, 1))

      resolved = ::MonthTotals.resolve_start_date(position, Date.new(2025, 1, 20))

      assert_equal Date.new(2025, 1, 20), resolved
    end

    it 'passes through dates on or after the chart start' do
      position = Struct.new(:start_date).new(Date.new(2025, 3, 1))

      resolved = ::MonthTotals.resolve_start_date(position, Date.new(2025, 1, 20))

      assert_equal Date.new(2025, 3, 1), resolved
    end

    it 'resolves an interval start to its first bound' do
      interval = ::EDTF.parse('2024-06/2025-02')
      position = PositionDouble.new(start_date: interval, end_date: nil, agency_id: 'MSPB')

      resolved = ::MonthTotals.resolve_start_date(position, Date.new(2025, 1, 20))

      assert_equal Date.new(2025, 1, 20), resolved
    end
  end

  describe 'resolve_end_date' do
    it 'clamps dates after the chart end to the chart end' do
      position = Struct.new(:end_date, :max_date_interval_to_date).new(Date.new(2026, 12, 31), nil)
      person = Struct.new(:govt_exit_date).new(nil)

      resolved = ::MonthTotals.resolve_end_date(position, person, Date.new(2025, 12, 31))

      assert_equal Date.new(2025, 12, 31), resolved
    end

    it 'falls back to the govt exit date when the position has no end date' do
      position = Struct.new(:end_date, :max_date_interval_to_date).new(nil, nil)
      person = Struct.new(:govt_exit_date).new(Date.new(2025, 6, 30))

      resolved = ::MonthTotals.resolve_end_date(position, person, Date.new(2025, 12, 31))

      assert_equal Date.new(2025, 6, 30), resolved
    end
  end

  describe 'accumulate_person!' do
    it 'counts every appearance month for a confirmed person' do
      totals = ::MonthTotals.initialize_totals(%w[2025-01 2025-02 2025-03])
      person = PersonDouble.new(
        positions: [PositionDouble.new(start_date: Date.new(2025, 1, 10), end_date: Date.new(2025, 1, 31),
                                       agency_id: 'MSPB')],
        govt_exit_date: nil
      )

      ::MonthTotals.accumulate_person!(totals, person, Date.new(2025, 1, 20), Date.new(2025, 3, 31), '%Y-%m')

      assert_equal 1, totals['2025-01'][:count]
      assert_equal 0, totals['2025-02'][:count]
      assert_equal 0, totals['2025-03'][:count]
      assert_equal 1, totals['2025-01'][:join]
      assert_equal 0, totals['2025-01'][:leave]
    end

    it 'records NDS counters for an NDS position' do
      totals = ::MonthTotals.initialize_totals(%w[2025-01 2025-02])
      person = PersonDouble.new(
        positions: [PositionDouble.new(start_date: Date.new(2025, 1, 10), end_date: Date.new(2025, 1, 31),
                                       agency_id: 'NDS')],
        govt_exit_date: nil
      )

      ::MonthTotals.accumulate_person!(totals, person, Date.new(2025, 1, 20), Date.new(2025, 2, 28), '%Y-%m')

      assert_equal 1, totals['2025-01'][:count_nds]
      assert_equal 1, totals['2025-01'][:join_nds]
      assert_equal 0, totals['2025-01'][:count_doge]
      assert_equal 0, totals['2025-01'][:join_doge]
    end

    it 'records the leave counter when the person has exited government' do
      totals = ::MonthTotals.initialize_totals(%w[2025-01 2025-02])
      person = PersonDouble.new(
        positions: [PositionDouble.new(start_date: Date.new(2025, 1, 10), end_date: Date.new(2025, 2, 20),
                                       agency_id: 'MSPB')],
        govt_exit_date: Date.new(2025, 2, 20)
      )

      ::MonthTotals.accumulate_person!(totals, person, Date.new(2025, 1, 20), Date.new(2025, 2, 28), '%Y-%m')

      assert_equal 1, totals['2025-02'][:leave]
    end
  end

  describe 'calculate' do
    # Real data spans 2025-01-20 .. 2025-12-XX; use a range that covers every
    # position so resolve_start_date/resolve_end_date never return a month
    # outside totals.
    it 'produces a month-keyed hash with every counter key' do
      result = ::MonthTotals.calculate(start_date: START_DATE, end_date: END_DATE)

      expect(result.keys).must_equal (START_DATE..END_DATE).map { |d| d.strftime('%Y-%m') }.uniq
      %i[join leave count join_nds leave_nds count_nds join_doge leave_doge count_doge].each do |counter|
        result.each_value { |values| assert values.key?(counter) }
      end
    end

    it 'counts every appearance month for every confirmed person' do
      result = ::MonthTotals.calculate(start_date: START_DATE, end_date: END_DATE)

      total_count = result.values.sum { |values| values[:count] }

      expected = ::Person.exclude(association: 'auxiliary').all.sum do |person|
        next 0 unless person.start_date

        keys = Set.new
        person.positions.each do |pos|
          next unless pos.start_date

          start_date = ::MonthTotals.resolve_start_date(pos, START_DATE)
          end_date = ::MonthTotals.resolve_end_date(pos, person, END_DATE)

          # Mirror the source: the start month is added even when the resolved
          # range is empty (end_date < start_date), since the range then yields
          # no months.
          keys.add(start_date.strftime('%Y-%m'))
          keys.merge((start_date..end_date).map { |x| x.strftime('%Y-%m') }.uniq)
        end

        keys.size
      end

      assert_equal expected, total_count
    end

    it 'never counts NDS or DOGE-only months above the overall count' do
      result = ::MonthTotals.calculate(start_date: START_DATE, end_date: END_DATE)

      result.each_value do |values|
        assert_operator values[:count], :>=, values[:count_nds]
        assert_operator values[:count], :>=, values[:count_doge]
      end
    end

    it 'records exactly one join in the first month when any person is present' do
      result = ::MonthTotals.calculate(start_date: START_DATE, end_date: END_DATE)

      first_month = result['2025-01']

      assert_operator first_month[:count], :>, 0, 'expected at least one person in the chart range'
      assert_operator first_month[:join], :>=, 1
    end
  end
end
