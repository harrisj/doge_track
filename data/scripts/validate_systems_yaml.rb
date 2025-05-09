# frozen_string_literal: true

require 'yaml'
require 'date'
require 'edtf'

systems_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'systems.yaml')
aliases_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'aliases.yaml')

aliases = YAML.unsafe_load_file(aliases_file, symbolize_names: true)
systems = YAML.unsafe_load_file(systems_file, symbolize_names: true)

aliases_lookup = {}
aliases.select {|a| a[:name] }.each {|a| aliases_lookup[a[:id]] = a[:name]}

systems.each do |system_hash|
  raise "Missing ID for #{system_hash.inspect}" unless system_hash.key? :id

  system_hash.fetch(:access, []).each do |sa|
    raise "Missing ID for system role #{sa.inspect}" unless sa.key? :id
    raise "Must have name or alias for #{sa.inspect}" unless sa[:name] || sa[:alias]

    if sa[:alias]
      if aliases_lookup.key? sa[:alias]
        sa[:name] = aliases_lookup[sa[:alias]]
      else
        sa[:name] = nil  # In case name was set before
      end
    end
  end
end

out = systems.sort_by { |s| s[:name] }

File.open(systems_file, 'w') do |file|
  schema_hdr = "# yaml-language-server: $schema=../schemas/systems-file.json\n"
  out_yaml = YAML.dump(out, line_width: 150, stringify_names: true, header: false)
  file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
end
