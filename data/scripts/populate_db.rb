# frozen_string_literal: true

require 'sequel'
DB_PATH = File.join(File.dirname(__FILE__), '..', 'doge.db')
DB = Sequel.sqlite(DB_PATH)

require 'require_all'
require_all File.join(File.dirname(__FILE__), '..', '..', 'models')
require 'edtf'
require 'yaml'

YAML_DIR = File.join(File.dirname(__FILE__), '..', 'raw_data')
DEFAULT_POS_SORT_APPOINTED = '2025-01-20'
DEFAULT_POS_SORT_OTHER = '2026-07-04'

def link_sources(record, sources)
  Array(sources).each do |src|
    source = Source[src] || raise("Unable to find source #{src}")
    record.add_source(source)
  end
end

def link_projects(record, projects)
  Array(projects).each do |pj|
    project = Project[pj] || raise("Can't find project #{pj}")
    record.add_project(project)
  end
end

def apply_position_sort_defaults(pos_hash)
  pos_hash[:sort_date] ||= pos_hash[:start_date]
  pos_hash[:sort_date] ||= DEFAULT_POS_SORT_APPOINTED if pos_hash[:type] == 'appointed'
  pos_hash[:sort_date] ||= DEFAULT_POS_SORT_OTHER
  pos_hash[:category] ||= 'unknown'
end

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
Entity.unrestrict_primary_key
Affiliation.unrestrict_primary_key

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
    Bridgetown.logger.error "Error loading event #{event_hash.inspect}"
    throw e
  end

  if event_hash.key? :case_no
    court_case = Case[event_hash[:case_no]]
    e.case = court_case
  end

  link_projects(e, event_hash[:project])

  agency_ids = Array(event_hash[:agency])
  names = (event_hash.fetch(:named, []) + event_hash.fetch(:linked, [])).uniq

  link_sources(e, event_hash[:source])

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
    a = Agency[agency_id] || raise("Unable to find agency #{agency_id}")
    e.add_agency(a)
  end

  e.save_changes
end

def load_agencies
  events = []
  Dir.glob(File.join(YAML_DIR, 'agencies', '*.yaml')).each do |agency_file|
    agency_data = YAML.unsafe_load_file(agency_file, symbolize_names: true)
    # agency_data should be a hash (one agency)
    Agency.create(agency_data.except(:events))
    events += agency_data.fetch(:events, [])
  end
  events
end

def load_publishers
  YAML.unsafe_load_file(File.join(YAML_DIR, 'publishers.yaml'), symbolize_names: true).each { |p| Publisher.create(p) }
end

def load_sources
  YAML.unsafe_load_file(File.join(YAML_DIR, 'sources.yaml'), symbolize_names: true).each { |s| Source.create(s) }
end

def load_projects
  YAML.unsafe_load_file(File.join(YAML_DIR, 'projects.yaml'), symbolize_names: true).each { |p| Project.create(p) }
end

def load_entities
  entities_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'entities.yaml'), symbolize_names: true)
  entities_yaml.each do |entity|
    Entity.create(entity.except('source')) # Not processing these yet
  end
end

def load_people
  Dir.glob(File.join(YAML_DIR, 'people', '*.yaml')).each do |person_file|
    p_hash = YAML.unsafe_load_file(person_file, symbolize_names: true)

    p_hash[:tech_links] = p_hash[:tech_links].join(', ') if p_hash[:tech_links]
    # If association is not set in YAML (blank/nil) and the person has no positions, set to "auxiliary"
    # Otherwise rely on DB default "confirmed" (which sets "confirmed" for people with positions)
    p_hash[:association] ||= 'auxiliary' if p_hash[:positions].empty?
    p = Person.new(p_hash.except(:positions, :alias, :affiliations, :source))

    p_hash.fetch(:positions, []).each do |pos_hash|
      pos_hash.transform_keys!(alias: :doge_alias_id, from: :from_agency_id, agency: :agency_id)
      pos_hash[:name] = p.name

      apply_position_sort_defaults(pos_hash)

      pos = Position.create(pos_hash.except(:source, :source_name, :project))

      link_sources(pos, pos_hash[:source])
      link_projects(pos, pos_hash[:project])
    end

    p.save_changes

    p_hash.fetch(:affiliations, []).each do |a_hash|
      affiliation = Affiliation.create(a_hash.except(:source).merge({ name: p.name }))

      link_sources(affiliation, a_hash[:source])

      affiliation.save_changes
    end
  end
end

def load_aliases
  Dir.glob(File.join(YAML_DIR, 'aliases', '*.yaml')).each do |alias_file|
    alias_hash = YAML.unsafe_load_file(alias_file, symbolize_names: true)

    a = DogeAlias.new(alias_hash.slice(:id))

    agency = Agency[alias_hash[:agency]]
    a.agency = agency

    if alias_hash.key? :name
      person = Person[alias_hash[:name]]
      a.person = person
    end

    a.evidence = alias_hash[:evidence].map { |x| "- #{x.strip}" }.join("\n") if alias_hash.key? :evidence

    a.save_changes

    Array(alias_hash[:source]).each do |src|
      source = Source[src] || raise("Unable to find source #{src} in event")
      a.add_source(source)
    end

    # Positions with names have already been loaded
    next if a.name

    alias_hash.fetch(:positions, []).each do |pos_hash|
      pos_hash.transform_keys!(alias: :doge_alias_id, from: :from_agency_id, agency: :agency_id)
      pos_hash[:doge_alias_id] = a.id
      apply_position_sort_defaults(pos_hash)

      pos = Position.create(pos_hash.except(:source))

      link_sources(pos, pos_hash[:source])
    end
  end
end

def load_cases
  cases_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'cases.yaml'), symbolize_names: true)

  cases_yaml.each do |case_hash|
    c = Case.create(case_hash.slice(:case_no, :name, :description, :date_filed, :status, :link))

    Array(case_hash[:agency]).each do |agency_id|
      a = Agency[agency_id]
      c.add_agency(a)
    end
  end
end

def load_questions
  questions_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'questions.yaml'), symbolize_names: true)

  questions_yaml.each do |q_hash|
    next if q_hash.nil?

    input_hash = q_hash.transform_keys!(alias: :doge_alias_id, system_id: :govt_system_id)
    Question.create(input_hash)
  end
end

def load_executive_orders
  exec_orders_yaml = YAML.unsafe_load_file(File.join(YAML_DIR, 'exec_orders.yaml'), symbolize_names: true)

  exec_orders_yaml.each do |eo_hash|
    eo = ExecutiveOrder.create(eo_hash.except(:agencies))
    eo_hash.fetch(:agencies, []).each do |a_id|
      agency = Agency[a_id]
      eo.add_agency(agency)
    end
  end
end

def load_systems
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
      link_sources(role, access_hash[:source])
    end

    link_projects(s, input_hash[:project])
  end
end

def load_interagency_events
  YAML.unsafe_load_file(File.join(YAML_DIR, 'interagency.yaml'), symbolize_names: true)
end

all_events = load_agencies
load_publishers
load_sources
load_projects
load_entities
load_people
load_aliases
load_cases
load_questions
load_executive_orders
load_systems

all_events += load_interagency_events

sorted_events = all_events.each_with_index.sort_by { |e, idx| [Date.edtf(e[:date].to_s), idx] }.map(&:first)

sorted_events.each do |event|
  create_event(event)
end
