# frozen_string_literal: true

require 'yaml'
require 'uri'
require 'date'

publishers_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'publishers.yaml')
sources_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'sources.yaml')

publishers = YAML.unsafe_load_file(publishers_file, symbolize_names: true)
sources = YAML.unsafe_load_file(sources_file, symbolize_names: true)

publishers_by_hostname = publishers.to_h { |p| [p[:hostname], p] }

sources.each do |source|
  next if source[:pub_id]

  uri = URI.parse(source[:url])
  raise "Can't parse #{source[:url]}" if uri.nil? || uri.host.nil?

  hostname = uri.host.gsub(/^www\./, '').strip
  publisher = publishers_by_hostname[hostname]
  raise "Couldn't find publisher for host #{hostname}" if publisher.nil?

  source[:pub_id] = publisher.id
end

publishers.sort_by! { |pub| pub[:id] }
sources.sort_by! { |src| src[:url] }

File.open(publishers_file, 'w') do |file|
  schema_hdr = "# yaml-language-server: $schema=../schemas/publishers-file.json\n"
  out_yaml = YAML.dump(publishers, line_width: 100, stringify_names: true, header: false)
  file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
end

File.open(sources_file, 'w') do |file|
  schema_hdr = "# yaml-language-server: $schema=../schemas/sources-file.json\n"
  out_yaml = YAML.dump(sources, line_width: 100, stringify_names: true, header: false)
  file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
end
