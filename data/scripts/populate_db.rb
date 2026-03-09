# frozen_string_literal: true

require 'sequel'
DB_PATH = File.join(File.dirname(__FILE__), '..', 'doge.sqlite')
DB = Sequel.sqlite(DB_PATH)

require 'require_all'
require_all File.join(File.dirname(__FILE__), '..', '..', 'models')
require 'edtf'
require 'yaml'

YAML_DIR = File.join(File.dirname(__FILE__), '..', 'raw_data')
DEFAULT_POS_SORT_APPOINTED = '2025-01-20'
DEFAULT_POS_SORT_OTHER = '2026-07-04'

# Let us assign primary key
Agency.unrestrict_primary_key
DogeAlias.unrestrict_primary_key
Person.unrestrict_primary_key
Event.unrestrict_primary_key
Position.unrestrict_primary_key
Case.unrestrict_primary_key
GovtSystem.unrestrict_primary_key
SystemRole.unrestrict_primary_key
Question.unrestrict_primary_key
ExecutiveOrder.unrestrict_primary_key
Source.unrestrict_primary_key
Publisher.unrestrict_primary_key
Project.unrestrict_primary_key

all_events = []

def create_event(event_hash)
  raise "Event is missing a unique ID: #{event_hash.inspect}" unless event_hash.key? :id

  event_date = event_hash[:date].is_a?(Date) ? event_hash[:date].edtf : event_hash[:date]

  event_hash.transform_keys!(event: :text, system: :system_id)
  event_hash[:date] = event_date
  event_hash[:sort_date] = Date.edtf!(event_date.to_s).to_s

  begin
    e = Event.create(event_hash.except(:case_no, :named, :linked, :named_aliases, :agency, :interagency_doge_reps,
                                       :source, :project))
  rescue Sequel::ValidationFailed => e
    puts "Error loading event #{event_hash.inspect}"
    throw e
  end

  if event_hash.key? :case_no
    court_case = Case[event_hash[:case_no]]
    e.case = court_case
  end

  Array(event_hash[:project]).each do |pj|
    project = Project[pj] || raise("Can't find project #{pj}")
    e.add_project(project)
  end

  agency_ids = Array(event_hash[:agency])
  names = (event_hash.fetch(:named, []) + event_hash.fetch(:linked, [])).uniq

  Array(event_hash[:source]).each do |src|
    source = Source[src] || raise("Unable to find source #{src} in DB")
    e.add_source(source)
  end

  event_hash.fetch(:named_aliases, []).each do |doge_alias_id|
    a = DogeAlias[doge_alias_id]
    raise "Couldn't find alias #{doge_alias_id} in event" if a.nil?

    e.add_doge_alias(a)
    names.append(a.name) if a.name
  end

  if event_hash.key? :interagency_doge_reps
    agency_ids += event_hash[:interagency_doge_reps].keys.map(&:to_s)
    event_hash[:interagency_doge_reps].each_value do |ia_names|
      names += Array(ia_names)
    end
  end

  names.uniq.each do |name|
    p = Person[name] || raise("Unable to find person #{name}")
    e.add_person(p)
  end

  agency_ids.uniq.each do |agency_id|
    a = Agency[agency_id]
    e.add_agency(a)
  end

  e.save_changes
end

# Load Agencies
agencies_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'agencies.yaml'), symbolize_names: true)
agencies_yaml.each do |a|
  Agency.create(a.except(:events))
  all_events += a.fetch(:events, [])
end

# Load publishers
publishers_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'publishers.yaml'), symbolize_names: true)
publishers_yaml.each do |p|
  Publisher.create(p)
end

# Load sources
sources_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'sources.yaml'), symbolize_names: true)
sources_yaml.each do |src|
  Source.create(src)
end

# Load projects
projects_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'projects.yaml'), symbolize_names: true)
projects_yaml.each do |src|
  Project.create(src)
end

# Load People
people_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'people.yaml'), symbolize_names: true)

people_yaml.each do |p_hash|
  p_hash[:tech_links] = p_hash[:tech_links].join(', ') if p_hash[:tech_links]
  p = Person.new(p_hash.except(:positions, :alias, :category, :connections, :source))

  p_hash.fetch(:positions, []).each do |pos_hash|
    pos_hash.transform_keys!(alias: :doge_alias_id, from: :from_agency_id, agency: :agency_id)
    pos_hash[:name] = p.name

    pos_hash[:sort_date] ||= pos_hash[:start_date]
    pos_hash[:sort_date] ||= DEFAULT_POS_SORT_APPOINTED if pos_hash[:type] == 'appointed'
    pos_hash[:sort_date] ||= DEFAULT_POS_SORT_OTHER
    pos_hash[:category] ||= 'unknown'

    pos = Position.create( # .reject { |k, _| %i[from alias agency].include?(k) })
      pos_hash.except(:source, :source_name, :project)
    )

    Array(pos_hash[:source]).each do |src|
      source = Source[src] || raise("Unable to find source #{src}")
      pos.add_source(source)
    end

    Array(pos_hash[:project]).each do |pj|
      project = Project[pj] || raise("Unable to find project #{pj}")
      pos.add_project(project)
    end

    # if pos_hash.key? :agency
    #   a = Agency[pos_hash[:agency]]
    #   pos.agency = a
    # end

    # if pos_hash.key? :from
    #   a = Agency[pos_hash[:from]]
    #   pos.from_agency = a
    # end
  end

  p.save_changes
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

  a.evidence = alias_hash[:evidence].map { |x| "- #{x.strip}" }.join("\n") if alias_hash.key? :evidence

  a.save_changes

  # Positions with names have already been loaded
  next if a.name

  alias_hash.fetch(:positions, []).each do |pos_hash|
    pos_hash.transform_keys!(alias: :doge_alias_id, from: :from_agency_id, agency: :agency_id)
    pos_hash[:doge_alias_id] = a.id
    pos_hash[:sort_date] ||= pos_hash[:start_date]
    pos_hash[:sort_date] ||= DEFAULT_POS_SORT_APPOINTED if pos_hash[:type] == 'appointed'
    pos_hash[:sort_date] ||= DEFAULT_POS_SORT_OTHER
    pos_hash[:category] ||= 'unknown'

    pos = Position.create(pos_hash.except(:source))

    Array(pos_hash[:source]).each do |src|
      source = Source[src] || raise("Unable to find source #{src}")
      pos.add_source(source)
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

questions_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'questions.yaml'), symbolize_names: true)
questions_yaml.each do |q_hash|
  next if q_hash.nil?

  input_hash = q_hash.transform_keys!(alias: :doge_alias_id, system_id: :govt_system_id)
  Question.create(input_hash)
end

exec_orders_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'exec_orders.yaml'), symbolize_names: true)
exec_orders_yaml.each do |eo_hash|
  eo = ExecutiveOrder.create(eo_hash.except(:agencies))
  eo_hash.fetch(:agencies, []).each do |a_id|
    agency = Agency[a_id]
    eo.add_agency(agency)
  end
end

systems_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'systems.yaml'), symbolize_names: true)

systems_yaml.each do |system_hash|
  input_hash = system_hash.transform_keys(alias: :doge_alias_id, agency: :agency_id)

  s = GovtSystem.create(input_hash.except(:access, :serves, :project))

  input_hash.fetch(:access, []).each do |access_hash|
    access_hash[:govt_system_id] = s.id
    # access_hash[:source] = Array(access_hash[:source]).join(', ') if access_hash.key? :source
    access_hash.transform_keys!({ alias: :doge_alias_id, agency: :agency_id })
    access_hash[:agency_id] ||= input_hash[:agency_id]
    role = SystemRole.create(access_hash.except(:source, :source_name))
    Array(access_hash[:source]).each do |src|
      source = Source[src] || raise("Unable to find source #{src}")
      role.add_source(source)
    end
  end

  Array(input_hash[:project]).each do |pj|
    project = Project[pj] || raise("Unable to find project #{pj}")
    s.add_project(project)
  end

  # system_hash.fetch(:serves, []).each do |name|
  #   a = Agency[name]
  #   s.add_serves(a)
  # end

  # s.save
end

interagency_events = YAML.unsafe_load_file(File.join(YAML_DIR, 'interagency.yaml'), symbolize_names: true)
all_events += interagency_events

sorted_events = all_events.each_with_index.sort_by { |e, idx| [Date.edtf(e[:date].to_s), idx] }.map(&:first)

sorted_events.each do |event|
  create_event(event)
end
