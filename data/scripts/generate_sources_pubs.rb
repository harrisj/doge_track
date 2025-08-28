# frozen_string_literal: true

require 'yaml'
require 'uri'
require 'date'

def source_from_event!(event, sources_by_url, publishers_by_hostname)
  event_source = event[:source]
  return if event_source.nil?

  return if sources_by_url.key?(event_source)

  uri = URI.parse(event_source)
  raise "Can't parse #{event_source}" if uri.nil? || uri.host.nil?

  host = uri.host.gsub(/^www\./, '').strip

  publisher = publishers_by_hostname[host]

  unless publisher
    puts "No publisher for #{host}"
    return
  end

  sources_by_url[event_source] = {
    url: event_source,
    pub_id: publisher[:id],
    title: nil,
    pub_date: nil
  }
end

publishers_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'publishers.yaml')
publishers = YAML.unsafe_load(File.read(publishers_file), symbolize_names: true)
publishers_by_hostname = publishers.to_h { |pub| [pub[:hostname], pub] }

File.join(File.dirname(__FILE__), '..', 'raw_data', 'sources.yaml')
sources = YAML.unsafe_load(File.read(publishers_file), symbolize_names: true)
sources_by_url = sources.reject { |s| s[:url].nil? }.to_h { |src| [src[:url], src] }

interagency_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'interagency.yaml')
agencies_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'agencies.yaml')

interagency = YAML.unsafe_load(File.read(interagency_file), symbolize_names: true)
agencies = YAML.unsafe_load(File.read(agencies_file), symbolize_names: true)

people_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'people.yaml')
people = YAML.unsafe_load(File.read(people_file), symbolize_names: true)

systems_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'systems.yaml')
systems = YAML.unsafe_load(File.read(systems_file), symbolize_names: true)

agencies.each do |agency|
  agency[:events].each do |event|
    source_from_event!(event, sources_by_url, publishers_by_hostname)
  end
end

interagency.each do |event|
  source_from_event!(event, sources_by_url, publishers_by_hostname)
end

people.each do |person|
  person[:positions].each do |pos|
    source_from_event!(pos, sources_by_url, publishers_by_hostname)
  end
end

systems.each do |system|
  next unless system[:access]

  system[:access].each do |role|
    source_from_event!(role, sources_by_url, publishers_by_hostname)
  end
end

out_sources_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'sources_out.yaml')
File.open(out_sources_file, 'w') do |file|
  schema_hdr = "# yaml-language-server: $schema=../schemas/sources-file.json\n"
  out_yaml = YAML.dump(sources_by_url.values, line_width: 100, stringify_names: true, header: false)
  file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
end
