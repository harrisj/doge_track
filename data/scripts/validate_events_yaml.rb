# frozen_string_literal: true

require 'yaml'
require 'date'
require 'edtf'
require 'shortuuid'
require 'fileutils'

SCRIPTS_DIR = File.join(File.dirname(__FILE__), '..', 'scripts')

CASES_DIR = File.join(SCRIPTS_DIR, '..', 'raw_data', 'cases')
AGENCIES_DIR = File.join(SCRIPTS_DIR, '..', 'raw_data', 'agencies')
INTERAGENCY_FILE = File.join(SCRIPTS_DIR, '..', 'raw_data', 'interagency.yaml')

cases_files = Dir[File.join(CASES_DIR, '*.yaml')]
cases = cases_files.map { |f| YAML.unsafe_load_file(f, symbolize_names: true) }.flatten

agencies_files = Dir[File.join(AGENCIES_DIR, '*.yaml')]
# Exclude interagency.yaml from regular agencies since it's separate
regular_agency_files = agencies_files.reject { |f| File.basename(f) == 'interagency.yaml' }
agencies = regular_agency_files.map { |f| YAML.unsafe_load_file(f, symbolize_names: true) }.flatten

interagency_file = INTERAGENCY_FILE
interagency = YAML.unsafe_load_file(interagency_file, symbolize_names: true)

def validate_event(event, _cases)
  unless event[:id]
    id = SecureRandom.uuid
    event[:id] = ShortUUID.shorten(id)[0...8]
  end

  event.except!(:source_name, :source_title)

  raise "Event #{event.inspect} has no source" unless event.key?(:source)

  event
end

def validate_agency(agency, short_name_uniq)
  raise "Missing short_name for agency #{agency.inspect}" unless agency[:short_name]

  raise "Short name #{agency[:short_name]} is not unique" if short_name_uniq.include? agency[:short_name]

  short_name_uniq.add(agency[:short_name])
end

events = interagency.map do |e|
  validate_event(e, cases)
end

short_name_uniq = Set.new

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

# Don't sort by index for interagency since it has no index
sorted_events = events.sort_by { |e| [Date.edtf(e[:date].to_s), e[:id]] }

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

# Write back
File.open(interagency_file, 'w') do |file|
  schema_hdr = "# yaml-language-server: $schema=../schemas/interagency-events-file.json\n"
  out_yaml = YAML.dump(interagency_events, line_width: 100, stringify_names: true, header: false)
  file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
end

# Write back regular agency YAMLs
agencies.each do |a|
  slug = a[:slug] || a[:id]
  if slug.nil? || slug == 'interagency'
    # Skip interagency agency if it appears in regular agencies
    next
  end

  agent_file = File.join(AGENCIES_DIR, "#{slug}.yaml")
  schema_hdr = "# yaml-language-server: $schema=../../schemas/agency.json\n"
  out_yaml = YAML.dump(a, line_width: 100, stringify_names: true, header: false)
  File.open(agent_file, 'w') do |file|
    file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
  end
end
