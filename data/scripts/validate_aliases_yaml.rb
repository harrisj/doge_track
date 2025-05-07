# frozen_string_literal: true

require 'yaml'
require 'date'
require 'edtf'

aliases_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'aliases.yaml')
out_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'processed_aliases.yaml')

aliases = YAML.unsafe_load_file(aliases_file, symbolize_names: true)

named_by_agency = {}

aliases.each do |a|
  unless a.key? :id
    raise "No ID found for #{a}"
  end

  unless a.key? :agency
    raise "No agency found for #{a[:id]}"
  end

  if a.key? :name
    named_by_agency[a[:agency]] ||= {}
    named_by_agency[a[:agency]][a[:name]] ||= []
    named_by_agency[a[:agency]][a[:name]].append(a[:id])    
  end
end

multiple_mappings = []
named_by_agency.each do |agency, alias_names|
  alias_names.each do |name, aliases|
    multiple_mappings.append({agency: agency, name: name, aliases: aliases}) if aliases.size > 1
  end
end

if multiple_mappings.size > 0
  error = multiple_mappings.map {|rec| "#{rec[:agency]}> #{rec[:name]} -> #{rec[:aliases].join(", ")}" }.join("; ")
  raise "Multiple mappings at same agency: #{error}"
end

out = aliases.sort_by { |a| a[:id] }

File.open(out_file, 'w') do |file|
  schema_hdr = "# yaml-language-server: $schema=../schemas/aliases-file.json\n"
  out_yaml = YAML.dump(out, line_width: 200, stringify_names: true, header: false)
  file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
end

File.rename(out_file, aliases_file)
