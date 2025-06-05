# frozen_string_literal: true

require 'yaml'
require 'date'
require 'edtf'

people_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'people.yaml')
aliases_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'aliases.yaml')
out_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'processed_people.yaml')

aliases = YAML.unsafe_load_file(aliases_file, symbolize_names: true)
people = YAML.unsafe_load_file(people_file, symbolize_names: true)

named_aliases = aliases.select { |a| a[:name] && a[:positions] }
named_alias_positions = named_aliases.map do |a|
  a[:positions].map do |p|
    p[:name] = a[:name]
    p[:alias] = a[:id]
    p
  end
end.flatten

people.each do |p|
  raise "No name for #{p}" unless p[:name]

  # Delete aliased positions
  p[:positions]&.reject! { |pos| pos.key?(:alias) && !pos.key?(:same_as) }

  my_aliased_positions = named_alias_positions.select { |a| a[:name] == p[:name] }
  if my_aliased_positions
    p[:positions] ||= []

    my_aliased_positions.each do |apos|
      if apos.key? :same_as
        pos = p[:positions].find { |x| x[:id] == apos[:same_as] }
        raise "Unable to find position #{apos[:same_as]} used in alias position" if pos.nil?
        unless apos[:name] == p[:name]
          raise "Position #{pos[:id]} has a different person (#{p[:name]}) than #{apos[:name]}"
        end

        apos.each do |k, v|
          pos[k] = v unless pos.key?(k)
        end
      else
        p[:positions].append(apos)
      end
    end
  end

  next unless p.key? :positions

  p[:positions] = p[:positions].sort_by do |pos|
    # Array-to-array error here means an EDTF date wasn't parsable

    if pos.key? :start_date
      date = Date.edtf(pos[:start_date].to_s)
      raise "Can't parse EDTF date #{pos[:start_date]}" if date.nil?

      [date, pos[:id]]
    else
      [Date.edtf('2025-01-20'), pos[:id]]
    end
  end
end

out = people.sort_by { |p| p[:sort_name] }

File.open(out_file, 'w') do |file|
  schema_hdr = "# yaml-language-server: $schema=../schemas/people-file.json\n"
  out_yaml = YAML.dump(out, line_width: 100, stringify_names: true, header: false)
  file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
end

File.rename(out_file, people_file)
