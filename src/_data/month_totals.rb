# frozen_string_literal: true

require 'date'
require 'edtf'

totals = {}

chart_start_date = Date.parse('2025-01-20')
chart_end_date = Date.today
key_format = '%Y-%m'

keys = (chart_start_date..chart_end_date).map { |x| x.strftime(key_format) }.uniq.sort

keys.each do |key|
  totals[key] = { join: 0, leave: 0, count: 0 }
end

Person.each do |person|
  next unless person.start_date

  person_keys_set = Set[]

  person.positions.each do |pos|
    next unless pos.start_date

    start_date = pos.start_date
    start_date = chart_start_date if start_date < chart_start_date

    end_date = pos.end_date || person.govt_exit_date || chart_end_date

    person_keys_set.add(start_date.strftime(key_format))
    person_keys_set.merge((start_date..end_date).map { |x| x.strftime(key_format) }.uniq)
  end

  person_keys = person_keys_set.to_a.sort

  person_keys.each do |key|
    totals[key][:count] += 1
  end

  totals[person_keys.first][:join] += 1
  totals[person_keys.last][:leave] += 1 if person.govt_exit_date
end

totals
