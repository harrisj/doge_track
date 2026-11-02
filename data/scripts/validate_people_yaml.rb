# frozen_string_literal: true

require 'yaml'
require 'date'
require 'edtf'
require 'shortuuid'
require 'fileutils'

PEOPLE_DIR = File.join(File.dirname(__FILE__), '..', 'raw_data', 'people')
ALIASES_DIR = File.join(File.dirname(__FILE__), '..', 'raw_data', 'aliases')

def load_aliases
  Dir[File.join(ALIASES_DIR, '*.yaml')]
    .map { |f| YAML.unsafe_load_file(f, symbolize_names: true) }
    .flatten
end

def load_people
  Dir[File.join(PEOPLE_DIR, '*.yaml')]
    .map { |f| YAML.unsafe_load_file(f, symbolize_names: true) }
    .flatten
end

def named_alias_positions(aliases)
  aliases.select { |a| a[:name] && a[:positions] }.map do |a|
    a[:positions].map do |p|
      p[:name] = a[:name]
      p[:alias] = a[:id]
      p
    end
  end.flatten
end

def resolve_alias_positions(person, alias_positions)
  person[:positions] ||= []

  alias_positions.select { |apos| apos[:name] == person[:name] }.each do |apos|
    if apos.key?(:same_as)
      pos = person[:positions].find { |x| x[:id] == apos[:same_as] }
      raise "Unable to find position #{apos[:same_as]} used in alias position" if pos.nil?

      unless apos[:name] == person[:name]
        raise "Position #{pos[:id]} has a different person (#{person[:name]}) than #{apos[:name]}"
      end

      apos.each { |k, v| pos[k] = v unless pos.key?(k) }
    else
      person[:positions].append(apos)
    end
  end
end

def assign_affiliation_ids(person)
  person[:affiliations]&.each do |affil|
    unless affil[:id]
      id = SecureRandom.uuid
      affil[:id] = ShortUUID.shorten(id)[0...8]
    end
  end
end

def sort_positions(person)
  return unless person.key?(:positions)

  person[:positions] = person[:positions].sort_by do |pos|
    # Array-to-array error here means an EDTF date wasn't parsable

    if pos.key?(:start_date)
      date = Date.edtf(pos[:start_date].to_s)
      raise "Can't parse EDTF date #{pos[:start_date]}" if date.nil?

      [date, pos[:id]]
    else
      [Date.edtf('2025-01-20'), pos[:id]]
    end
  end
end

def write_people(people)
  people.sort_by { |p| p[:sort_name] }.each do |p|
    slug = p[:slug]
    if slug.nil?
      Bridgetown.logger.info "Warning: person #{p[:name]} has no slug, skipping file write"
      next
    end

    person_file = File.join(PEOPLE_DIR, "#{slug}.yaml")
    schema_hdr = "# yaml-language-server: $schema=../../schemas/person.json\n"
    out_yaml = YAML.dump(p, line_width: 100, stringify_names: true, header: false)
    File.open(person_file, 'w') do |file|
      file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
    end
  end
end

def validate_people
  aliases = load_aliases
  people = load_people
  positions_by_name = named_alias_positions(aliases).group_by { |p| p[:name] }

  people.each do |p|
    raise "No name for #{p}" unless p[:name]

    # Delete aliased positions
    p[:positions]&.reject! { |pos| pos.key?(:alias) && !pos.key?(:same_as) }

    resolve_alias_positions(p, positions_by_name[p[:name]] || [])
    assign_affiliation_ids(p)
    sort_positions(p)
  end

  write_people(people.sort_by { |p| p[:sort_name] })
end

validate_people
