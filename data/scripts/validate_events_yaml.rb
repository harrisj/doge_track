# frozen_string_literal: true

require 'yaml'
require 'date'
require 'edtf'
require 'shortuuid'

SCRIPTS_DIR = File.join(File.dirname(__FILE__), '..', 'scripts')
AGENCIES_DIR = File.join(SCRIPTS_DIR, '..', 'raw_data', 'agencies')
INTERAGENCY_FILE = File.join(SCRIPTS_DIR, '..', 'raw_data', 'interagency.yaml')

def validate_event(event)
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

def load_agencies
  Dir[File.join(AGENCIES_DIR, '*.yaml')]
    .reject { |f| File.basename(f) == 'interagency.yaml' }
    .map { |f| YAML.unsafe_load_file(f, symbolize_names: true) }
    .flatten
end

def load_interagency_events
  YAML.unsafe_load_file(INTERAGENCY_FILE, symbolize_names: true).map { |e| validate_event(e) }
end

def validate_agency_events(agencies)
  events = []
  short_name_uniq = Set.new

  agencies.each do |agency|
    validate_agency(agency, short_name_uniq)

    agency[:events] ||= []
    agency[:events].each do |event|
      event[:agency] ||= agency[:id]
      events << validate_event(event)
    end

    agency[:events] = []
  end

  events
end

def sort_events(events)
  events.sort_by { |event| [EDTF.parse(event[:date].to_s), event[:id]] }
end

def split_events(sorted_events, agencies)
  interagency_events = []

  sorted_events.each do |event|
    event_agencies = Array(event[:agency])

    if event_agencies.size > 1
      interagency_events << event
      next
    end

    agency_id = event_agencies[0]
    agency = agencies.find { |a| a[:id] == agency_id }
    raise "Unable to find agency for #{agency_id}, aborting!" if agency.nil?

    agency[:events] << event
  end

  [interagency_events, agencies]
end

def write_interagency_file(interagency_events)
  File.open(INTERAGENCY_FILE, 'w') do |file|
    schema_hdr = "# yaml-language-server: $schema=../schemas/interagency-events-file.json\n"
    out_yaml = YAML.dump(interagency_events, line_width: 100, stringify_names: true, header: false)
    file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
  end
end

def write_agency_files(agencies)
  agencies.each do |agency|
    slug = agency[:slug] || agency[:id]
    next if slug.nil? || slug == 'interagency'

    agency_file = File.join(AGENCIES_DIR, "#{slug}.yaml")
    schema_hdr = "# yaml-language-server: $schema=../../schemas/agency.json\n"
    out_yaml = YAML.dump(agency, line_width: 100, stringify_names: true, header: false)
    File.open(agency_file, 'w') do |file|
      file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
    end
  end
end

agencies = load_agencies
events = load_interagency_events + validate_agency_events(agencies)
sorted_events = sort_events(events)
interagency_events, agencies = split_events(sorted_events, agencies)

write_interagency_file(interagency_events)
write_agency_files(agencies)
