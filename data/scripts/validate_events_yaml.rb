# frozen_string_literal: true

require 'yaml'
require 'date'
require 'edtf'
require 'shortuuid'

cases_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'cases.yaml')
cases = YAML.unsafe_load(File.read(cases_file), symbolize_names: true)

def validate_agency(agency, short_name_uniq)
  raise "Missing short_name for agency #{agency.inspect}" unless agency[:short_name]

  raise "Short name #{agency[:short_name]} is not unique" if short_name_uniq.include? agency[:short_name]

  short_name_uniq.add(agency[:short_name])
end

def validate_event(event, cases)
  unless event[:id]
    id = SecureRandom.uuid
    event[:id] = ShortUUID.shorten(id)[0...8]
  end

  if event[:case_no] && !event[:source_name]
    event[:source_name] = 'Court Filing'
    event[:source_title] = cases.find { |c| c[:case_no] == event[:case_no] }.fetch(:name)
  end

  event
end

interagency_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'interagency.yaml')
agencies_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'agencies.yaml')

interagency = YAML.unsafe_load(File.read(interagency_file), symbolize_names: true)
agencies = YAML.unsafe_load(File.read(agencies_file), symbolize_names: true)

events = interagency.map do |e|
  validate_event(e, cases)
end

short_name_uniq = Set[]

agencies.each do |a|
  validate_agency(a, short_name_uniq)

  a[:events] ||= []
  a[:events].each do |e|
    e[:agency] ||= a[:id]
    events.append(validate_event(e, cases))
  end

  # Don't worry, we'll add them back
  a[:events] = []
end

sorted_events = events.each_with_index.sort_by { |e, idx| [Date.edtf(e[:date].to_s), idx] }.map(&:first)

interagency_events = []

sorted_events.each do |event|
  event_agencies = Array(event[:agency])
  if event_agencies.size > 1
    interagency_events.append(event)
  else
    agency_id = event_agencies[0]
    agency = agencies.find { |a| a[:id] == agency_id }
    raise "Unable to find agency for #{agency_id}, aborting!" if agency.nil?

    agency[:events].append(event)
  end
end

File.open(interagency_file, 'w') do |file|
  schema_hdr = "# yaml-language-server: $schema=../schemas/interagency-events-file.json\n"
  out_yaml = YAML.dump(interagency_events, line_width: 150, stringify_names: true, header: false)
  file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
end

File.open(agencies_file, 'w') do |file|
  schema_hdr = "# yaml-language-server: $schema=../schemas/agencies-file.json\n"
  out_yaml = YAML.dump(agencies, line_width: 150, stringify_names: true, header: false)
  file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
end
