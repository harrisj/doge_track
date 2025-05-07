# frozen_string_literal: true

require 'yaml'
require 'date'
require 'edtf'

people_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'people.yaml')
out_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'processed_people.yaml')

people = YAML.unsafe_load_file(people_file, symbolize_names: true)

people.each do |p|
  # Any validation I need to do here?
  if p.key? :positions

    p[:positions] = p[:positions].sort_by do |pos| 
      if pos.key? :start_date
        Date.edtf(pos[:start_date].to_s)
      else
        Date.edtf("2025-01-20")
      end
    end
  else
    puts "No positions found for #{p[:name]}"
  end
end

out = people.sort_by { |p| p[:sort_name] }

File.open(out_file, 'w') do |file|
  schema_hdr = "# yaml-language-server: $schema=../schemas/people-file.json\n"
  file.write(schema_hdr, YAML.dump(out, line_width: 100, stringify_names: true, header: false))
end

# File.rename(out_file, events_file)
