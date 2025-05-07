# frozen_string_literal: true

require 'yaml'
require 'date'
require 'edtf'

people_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'people.yaml')
aliases_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'aliases.yaml')
out_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'processed_people.yaml')

aliases = YAML.unsafe_load_file(aliases_file, symbolize_names: true)
people = YAML.unsafe_load_file(people_file, symbolize_names: true)

named_aliases = aliases.select {|a| a[:name] && a[:positions] }
named_alias_positions = named_aliases.map {|a| a[:positions].map {|p| p[:name] = a[:name]; p[:alias] = a[:id]; p}}.flatten

people.each do |p|
  raise "No name for #{p}" unless p[:name]

  if p[:positions]
    # Delete aliased positions  
    p[:positions].reject! {|pos| pos.key? :alias }
  end

  my_aliased_positions = named_alias_positions.select {|a| a[:name] == p[:name]}
  if my_aliased_positions
    p[:positions] ||= []
    p[:positions] += my_aliased_positions
  end

  if p.key? :positions
    p[:positions] = p[:positions].sort_by do |pos| 
      if pos.key? :start_date
        Date.edtf(pos[:start_date].to_s)
      else
        Date.edtf("2025-01-20")
      end
    end
  end
end

out = people.sort_by { |p| p[:sort_name] }

File.open(out_file, 'w') do |file|
  schema_hdr = "# yaml-language-server: $schema=../schemas/people-file.json\n"
  out_yaml = YAML.dump(out, line_width: 150, stringify_names: true, header: false)
  file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
end

File.rename(out_file, people_file)
