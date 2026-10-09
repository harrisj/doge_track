# frozen_string_literal: true

require './data/scripts/models'
require 'date'

# Chart date range for month totals calculation
chart_start_date = Date.parse('2025-01-20')
chart_end_date = Date.today
key_format = '%Y-%m'

# All month keys in the chart range (e.g., "2025-01", "2025-02", ...) sorted chronologically
keys = (chart_start_date..chart_end_date).map { |date| date.strftime(key_format) }.uniq.sort

# Initialize totals
# Internal format: each key maps to a hash with all counters
#   join, leave   — original DOGE join/leave (always counts first/last overall month if leave condition met)
#   join_nds, leave_nds — NDS join/leave (counts first/last NDS month if leave condition met)
#   join_doge, leave_doge — DOGE join/leave for DOGE-only months
#   count, count_nds, count_doge — overall count, NDS count, DOGE-only count
totals = {}
keys.each do |key|
  totals[key] = {
    join: 0, leave: 0,
    join_nds: 0, leave_nds: 0,
    join_doge: 0, leave_doge: 0,
    count: 0, count_nds: 0, count_doge: 0
  }
end

Person.all.each do |person|
  next unless person.start_date

  overall_keys_set = Set.new # months from all positions (overall timeline)
  nds_keys_set = Set.new # months from NDS positions only

  person.positions.each do |pos|
    next unless pos.start_date

    start_date = pos.start_date
    start_date = chart_start_date if start_date < chart_start_date
    end_date = pos.end_date || person.govt_exit_date || chart_end_date

    # Overall months
    overall_keys_set.add(start_date.strftime(key_format))
    overall_keys_set.merge((start_date..end_date).map { |x| x.strftime(key_format) }.uniq)

    # NDS months (only for NDS positions)
    next unless pos.agency_id == 'NDS'

    nds_start_date = start_date
    nds_end_date = end_date
    nds_keys_set.add(nds_start_date.strftime(key_format))
    nds_keys_set.merge((nds_start_date..nds_end_date).map { |x| x.strftime(key_format) }.uniq)
  end

  overall_keys = overall_keys_set.to_a.sort
  nds_keys = nds_keys_set.to_a.sort

  # Overall first/last (used for original join/leave)
  first_overall = overall_keys.first
  last_overall = overall_keys.last

  # NDS first/last
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
  next unless doge_keys.any?

  doge_keys.each do |key|
    totals[key][:count_doge] += 1
    totals[key][:join_doge] += 1 if key == first_doge
    totals[key][:leave_doge] += 1 if person.govt_exit_date && key == last_doge
  end
end

# Reshape totals to canonical output format
# { "2025-01" => { join: X, leave: Y, count: Z, join_nds: A, leave_nds: B,
# count_nds: C, join_doge: D, leave_doge: E, count_doge: F } }
result = {}
keys.each do |key|
  result[key] = {
    join: totals[key][:join], leave: totals[key][:leave], count: totals[key][:count],
    join_nds: totals[key][:join_nds], leave_nds: totals[key][:leave_nds], count_nds: totals[key][:count_nds],
    join_doge: totals[key][:join_doge], leave_doge: totals[key][:leave_doge], count_doge: totals[key][:count_doge]
  }
end

result
