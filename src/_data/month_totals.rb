# frozen_string_literal: true

require 'date'

# Chart date range for month totals calculation
chart_start_date = Date.parse('2025-01-20')
chart_end_date = Date.today
key_format = '%Y-%m'

# All month keys in the chart range (e.g., "2025-01", "2025-02", ...) sorted chronologically
keys = (chart_start_date..chart_end_date).map { |date| date.strftime(key_format) }.uniq.sort

# Initialize totals for each month: { join: 0, leave: 0, count: 0 }
totals = {}
keys.each do |key|
  totals[key] = { join: 0, leave: 0, count: 0 }
end

# Process each person in the database
Person.all.each do |person|
  # Skip persons without a start date
  next unless person.start_date

  # Collect all month keys for this person's positions using a Set for deduplication
  person_keys_set = Set.new

  person.positions.each do |pos|
    # Skip positions without a start date
    next unless pos.start_date

    start_date = pos.start_date
    # Clamp start date to the chart start if it is earlier
    start_date = chart_start_date if start_date < chart_start_date

    # Determine end date; use position end, or person's govt exit date, or chart end
    end_date = pos.end_date || person.govt_exit_date || chart_end_date

    # Add the start month
    person_keys_set.add(start_date.strftime(key_format))
    # Add all months from start to end (inclusive)
    person_keys_set.merge((start_date..end_date).map { |date| date.strftime(key_format) }.uniq)
  end

  person_keys = person_keys_set.to_a.sort

  # Increment count for each month the person appears
  person_keys.each do |key|
    totals[key][:count] += 1
  end

  # Increment join for the first month of the person's timeline
  totals[person_keys.first][:join] += 1
  # Increment leave for the last month if the person has a government exit date
  totals[person_keys.last][:leave] += 1 if person.govt_exit_date
end

# Return results in the canonical format: { "2025-01" => { join: 57, leave: 1, count: 57 }, ... }
# Reshape totals from {key => {join: X, leave: Y, count: 0}} to {key => {join: X, leave: Y, count: Z}}
result = {}
keys.each do |key|
  result[key] = {
    join: totals[key][:join],
    leave: totals[key][:leave],
    count: totals[key][:count]
  }
end

result
