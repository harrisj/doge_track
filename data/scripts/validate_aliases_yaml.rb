# frozen_string_literal: true

require 'yaml'
require 'date'
require 'edtf'
require 'fileutils'

ALIASES_DIR = File.join(File.dirname(__FILE__), '..', 'raw_data', 'aliases')

# Load all aliases from directory
alias_files = Dir[File.join(ALIASES_DIR, '*.yaml')]
aliases = alias_files.map { |f| YAML.unsafe_load_file(f, symbolize_names: true) }.flatten

named_by_agency = {}

aliases.each do |a|
  raise "No ID found for #{a}" unless a.key? :id

  raise "No agency found for #{a[:id]}" unless a.key? :agency

  next unless a.key? :name

  named_by_agency[a[:agency]] ||= {}
  named_by_agency[a[:agency]][a[:name]] ||= []
  named_by_agency[a[:agency]][a[:name]].append(a[:id])
end

multiple_mappings = []
named_by_agency.each do |agency, alias_names|
  alias_names.each do |name, name_aliases|
    multiple_mappings.append({ agency: agency, name: name, aliases: name_aliases }) if name_aliases.size > 1
  end
end

if multiple_mappings.size.positive?
  error = multiple_mappings.map { |rec| "#{rec[:agency]}> #{rec[:name]} -> #{rec[:aliases].join(', ')}" }.join('; ')
  raise "Multiple mappings at same agency: #{error}"
end

out = aliases.sort_by { |a| a[:id] }

# Write each processed alias back to its individual file
out.each do |a|
  slug = a[:slug] || a[:id]
  if slug.nil?
    Bridgetown.logger.info 'Warning: alias has no slug or id, skipping file write'
    next
  end
  alias_file = File.join(ALIASES_DIR, "#{slug}.yaml")
  schema_hdr = "# yaml-language-server: $schema=../schemas/aliases-file.json\n"
  out_yaml = YAML.dump(a, line_width: 100, stringify_names: true, header: false)
  File.open(alias_file, 'w') do |file|
    file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
  end
end
