# frozen_string_literal: true

require 'yaml'
require 'date'
require 'edtf'
require 'shortuuid'

events_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'events.yaml')
out_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'processed_events.yaml')

events = YAML.unsafe_load(File.read(events_file), symbolize_names: true)

events.each do |e|
  unless e[:id]
    id = SecureRandom.uuid
    e[:id] = ShortUUID.shorten(id)[0...8]
  end
end

out = events.each_with_index.sort_by { |e, idx| [Date.edtf(e[:date].to_s), idx] }.map(&:first)

File.open(out_file, 'w') do |file|
  schema_hdr = "# yaml-language-server: $schema=../schemas/events-file.json\n"
  out_yaml = YAML.dump(out, line_width: 150, stringify_names: true, header: false)
  file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
end

File.rename(out_file, events_file)
