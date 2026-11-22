# frozen_string_literal: true

require_relative '../../models/person'
require 'date'
require 'edtf'

# Computes per-month DOGE/NDS staffing totals for the timeline chart.
module MonthTotals
  CHART_START_DATE = Date.parse('2025-01-20')
  KEY_FORMAT = '%Y-%m'

  module_function

  # Build the canonical month-key => totals hash for the given date range.
  # `start_date` and `end_date` are injectable for testing; by default the
  # range runs from the chart start to today.
  def calculate(start_date: CHART_START_DATE, end_date: Date.today)
    key_format = KEY_FORMAT

    keys = (start_date..end_date).map { |date| date.strftime(key_format) }.uniq.sort
    totals = initialize_totals(keys)

    Person.exclude(association: 'auxiliary').all.each do |person|
      next unless person.start_date

      accumulate_person!(totals, person, start_date, end_date, key_format)
    end

    reshape_totals(totals, keys)
  end

  # Initialize totals
  # Internal format: each key maps to a hash with all counters
  #   join, leave   — original DOGE join/leave (always counts first/last overall month if leave condition met)
  #   join_nds, leave_nds — NDS join/leave (counts first/last NDS month if leave condition met)
  #   join_doge, leave_doge — DOGE join/leave for DOGE-only months
  #   count, count_nds, count_doge — overall count, NDS count, DOGE-only count
  def initialize_totals(keys)
    keys.to_h do |key|
      [
        key, {
          join: 0, leave: 0,
          join_nds: 0, leave_nds: 0,
          join_doge: 0, leave_doge: 0,
          count: 0, count_nds: 0, count_doge: 0
        }
      ]
    end
  end

  def accumulate_person!(totals, person, chart_start_date, chart_end_date, key_format)
    overall_keys_set = Set.new
    nds_keys_set = Set.new

    person.positions.each do |pos|
      next unless pos.start_date

      start_date = resolve_start_date(pos, chart_start_date)
      end_date = resolve_end_date(pos, person, chart_end_date)

      # Overall months
      overall_keys_set.add(start_date.strftime(key_format))
      overall_keys_set.merge((start_date..end_date).map { |x| x.strftime(key_format) }.uniq)

      # NDS months (only for NDS positions)
      next unless pos.agency_id == 'NDS'

      nds_keys_set.add(start_date.strftime(key_format))
      nds_keys_set.merge((start_date..end_date).map { |x| x.strftime(key_format) }.uniq)
    end

    overall_keys = overall_keys_set.to_a.sort
    nds_keys = nds_keys_set.to_a.sort

    first_overall = overall_keys.first
    last_overall = overall_keys.last

    first_nds = nds_keys.first if nds_keys.any?
    last_nds = nds_keys.last if nds_keys.any?

    # DOGE-only months (overall months that are NOT NDS months)
    doge_keys = overall_keys.reject { |k| nds_keys.include?(k) }
    first_doge = doge_keys.first if doge_keys.any?
    last_doge = doge_keys.last if doge_keys.any?

    # Add to overall counters (original behavior, always counts)
    overall_keys.each do |key|
      totals[key][:count] += 1 # original count counts every appearance month
      totals[key][:join] += 1 if key == first_overall # original join
      totals[key][:leave] += 1 if person.govt_exit_date && key == last_overall # original leave
    end

    # Add NDS counters ONLY if this person has any NDS positions in that month
    if nds_keys.any?
      nds_keys.each do |key|
        totals[key][:count_nds] += 1
        totals[key][:join_nds] += 1 if key == first_nds
        totals[key][:leave_nds] += 1 if person.govt_exit_date && key == last_nds
      end
    end

    # Add DOGE counters ONLY for DOGE-only months
    return unless doge_keys.any?

    doge_keys.each do |key|
      totals[key][:count_doge] += 1
      totals[key][:join_doge] += 1 if key == first_doge
      totals[key][:leave_doge] += 1 if person.govt_exit_date && key == last_doge
    end
  end

  def resolve_start_date(pos, chart_start_date)
    start_date = pos.start_date
    start_date = pos.min_interval_to_date(:start_date) || chart_start_date if start_date.is_a?(EDTF::Interval)
    start_date = chart_start_date if start_date < chart_start_date

    start_date
  end

  def resolve_end_date(pos, person, chart_end_date)
    end_date = pos.end_date
    end_date = pos.max_date_interval_to_date(:end_date) if end_date.is_a?(EDTF::Interval)
    end_date ||= person.govt_exit_date || chart_end_date
    end_date = chart_end_date if end_date > chart_end_date

    end_date
  end

  # Reshape totals to canonical output format
  # { "2025-01" => { join: X, leave: Y, count: Z, join_nds: A, leave_nds: B,
  # count_nds: C, join_doge: D, leave_doge: E, count_doge: F } }
  def reshape_totals(totals, keys)
    keys.to_h do |key|
      [
        key, {
          join: totals[key][:join], leave: totals[key][:leave], count: totals[key][:count],
          join_nds: totals[key][:join_nds], leave_nds: totals[key][:leave_nds], count_nds: totals[key][:count_nds],
          join_doge: totals[key][:join_doge], leave_doge: totals[key][:leave_doge], count_doge: totals[key][:count_doge]
        }
      ]
    end
  end
end

# Only auto-run when Bridgetown loads this file for a real build. In the test
# environment the eager model autoload leaves Position as a pending constant
# while the site exists, which would break the eager calculate call, so skip it
# and let callers call MonthTotals.calculate directly once the site is ready.
if ENV['BRIDGEOWN_ENV'] != 'test'
  result = MonthTotals.calculate
  result
end
