# frozen_string_literal: true

require 'date'
require 'edtf'

totals = {}

chart_start_date = Date.parse('2025-01-20')
chart_end_date = Date.today
key_format = '%Y-%m'

keys = (chart_start_date..chart_end_date).map { |x| x.strftime(key_format) }.uniq.sort

keys.each do |key|
  totals[key] = { join: 0, exit: 0, count: 0 }
end

Person.each do |person|
  next unless person.start_date

  start_date = Date.edtf(person.start_date)
  start_date = chart_start_date if start_date < chart_start_date

  end_date = Date.edtf(person.govt_exit_date) if person.govt_exit_date
  iter_end_date = end_date || chart_end_date

  totals[start_date.strftime(key_format)][:join] += 1
  totals[end_date.strftime(key_format)][:exit] += 1 if end_date

  person_keys = if end_date && start_date.month == end_date.month && start_date.year == end_date.year
                  [start_date.strftime(key_format)] # the same-month flameouts
                else
                  (start_date..iter_end_date).map { |x| x.strftime(key_format) }.uniq.sort
                end

  puts "#{person.name} #{person_keys}"

  person_keys.each do |key|
    totals[key][:count] += 1
  end
end

totals
