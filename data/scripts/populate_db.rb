# frozen_string_literal: true

require_relative 'models'
require 'edtf'
require 'sequel'
require 'yaml'

YAML_DIR = File.join(File.dirname(__FILE__), '..', 'raw_data')

# Let us assign primary key
Agency.unrestrict_primary_key
DogeAlias.unrestrict_primary_key
Person.unrestrict_primary_key
Event.unrestrict_primary_key
Position.unrestrict_primary_key
Case.unrestrict_primary_key
GovtSystem.unrestrict_primary_key
SystemRole.unrestrict_primary_key

# GovtSystem.plugin :nested_attributes
# GovtSystem.nested_attributes :system_roles

# Person.plugin :nested_attributes
# Person.nested_attributes :positions

# DogeAlias.plugin :nested_attributes
# DogeAlias.nested_attributes :positions

pos_hashes = []

# Load Agencies
agencies_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'agencies.yaml'), symbolize_names: true)
agencies_yaml.each do |a|
  Agency.create(a)
end

# Load People
people_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'people.yaml'), symbolize_names: true)

people_yaml.each do |p_hash|
  p = Person.new(p_hash.reject { |k, _| %i[positions alias].include?(k) })

  p_hash.fetch(:positions, []).each do |pos_hash|
    pos_hash.transform_keys!(alias: :doge_alias_id, from: :from_agency_id, agency: :agency_id)
    pos_hash[:name] = p.name
    pos_hash[:documents] = pos_hash[:documents].join(" ") if pos_hash[:documents]  # FIXME: load documents as separate table

    pos = Position.create(pos_hash) # .reject { |k, _| %i[from alias documents agency].include?(k) })

    # if pos_hash.key? :agency
    #   a = Agency[pos_hash[:agency]]
    #   pos.agency = a
    # end

    # if pos_hash.key? :from
    #   a = Agency[pos_hash[:from]]
    #   pos.from_agency = a
    # end
  end

  p.save
end

aliases_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'aliases.yaml'), symbolize_names: true)
aliases_yaml.each do |alias_hash|
  a = DogeAlias.new(alias_hash.slice(:id))

  agency = Agency[alias_hash[:agency]]
  a.agency = agency

  if alias_hash.key? :name
    person = Person[alias_hash[:name]]
    a.person = person
  end

  a.evidence = alias_hash[:evidence].join("\n") if alias_hash.key? :evidence
  a.save

  # Positions with names have already been loaded
  unless a.name
    alias_hash.fetch(:positions, []).each do |pos_hash|
      pos_hash.transform_keys!(alias: :doge_alias_id, from: :from_agency_id, agency: :agency_id)
      pos_hash[:doge_alias_id] = a.id
      pos_hash[:documents] = pos_hash[:documents].join(" ") if pos_hash[:documents]
      Position.create(pos_hash)
    end
  end
end

cases_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'cases.yaml'), symbolize_names: true)

cases_yaml.each do |case_hash|
  c = Case.create(case_hash.slice(:case_no, :name, :description, :date_filed, :status, :link))

  Array(case_hash[:agency]).each do |agency_id|
    a = Agency[agency_id]
    c.add_agency(a)
  end
end

systems_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'systems.yaml'), symbolize_names: true)

systems_yaml.each do |system_hash|
  input_hash = system_hash.transform_keys(alias: :doge_alias_id, agency: :agency_id)

  puts(input_hash)
  s = GovtSystem.create(input_hash.reject { |k, _| %i[access serves].include?(k) })

  input_hash.fetch(:access, []).each do |access_hash|
    access_hash[:govt_system_id] = s.id
    access_hash[:source] = Array(access_hash[:source]).join(', ') if access_hash.key? :source
    access_hash.transform_keys!({ alias: :doge_alias_id, agency: :agency_id })
    SystemRole.create(access_hash)
  end

  # system_hash.fetch(:serves, []).each do |name|
  #   a = Agency[name]
  #   s.add_serves(a)
  # end

  # s.save
end

events_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'events.yaml'), symbolize_names: true)

events_yaml.each do |event_hash|
  event_hash[:text] = event_hash[:event]
  date = Date.edtf(event_hash[:date].to_s)
  sort_date = Date.edtf(event_hash[:date].to_s).precise!

  e = Event.create({ id: event_hash[:id],
                     type: event_hash[:type],
                     date: date,
                     sort_date: sort_date,
                     time: event_hash[:time],
                     text: event_hash[:event],
                     fuzz: event_hash[:fuzz],
                     comment: event_hash[:comment],
                     source: event_hash[:source],
                     source_title: event_hash[:source_title],
                     source_name: event_hash[:source_name] })

  if event_hash.key? :case_no
    court_case = Case[event_hash[:case_no]]
    e.case = court_case
  end

  people_seen = {}
  event_hash.fetch(:named, []).each do |name|
    p = Person[name]
    people_seen[name] = true
    e.add_person(p)
  end

  event_hash.fetch(:named_aliases, []).each do |name|
    a = DogeAlias[name]

    if a&.person && !people_seen.key?(a.person.name)
      e.add_person(a.person)
      people_seen[a.person.name] = true
    end

    e.add_doge_alias(a)
  end

  Array(event_hash[:agency]).each do |agency_id|
    a = Agency[agency_id]
    e.add_agency(a)
  end

  e.save
end

# Now, if Aliases have been named, update the alias pointers to include names
# DB.run "UPDATE events e JOIN doge_aliases d ON d.id = e.doge_alias_id SET e.name = d.name WHERE d.name IS NOT NULL"

