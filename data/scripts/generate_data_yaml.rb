# frozen_string_literal: true

require 'date'
require 'yaml'
require 'fileutils'
require_relative 'models'
require 'edtf-humanize'

DATA_DIR = File.join(File.dirname(__FILE__), '..', '..', 'src', '_data')

def events_for_output(events)
  events.sort_by(&:sort_date).map do |e|
    e_out = e.to_hash
    e_out['agencies'] = e.agencies.map { |a| a.to_hash.slice(:id, :slug, :name, :short_name) }
    e_out['people'] = e.people.map { |x| x.to_hash.slice(:slug, :name, :sort_name) }

    e_out['aliases'] = []
    e.doge_aliases.each do |a|
      if a.person
        existing_record = e_out['people'].find { |p| p[:name] == a.name }
        existing_record[:alias] = a.id
      else
        e_out['aliases'].append(a.id)
      end
    end

    e_out
  end
end

def positions_for_output(positions)
  positions.sort_by(&:sort_date).map do |x|
    out = x.to_hash
    out['duration_summary'] = x.duration_summary
    out['agency'] = { agency_id: x.agency.id, name: x.agency.name, short_name: x.agency.short_name }
    if x.from_agency
      out['from_agency'] =
        { agency_id: x.from_agency.id, name: x.from_agency.name, short_name: x.from_agency.short_name }
    end
    out['person'] = x.person.to_hash.merge(obj_type: 'Person') unless x.person.nil?
    out['alias'] = x.doge_alias.to_hash.merge(obj_type: 'Alias') unless x.doge_alias.nil?
    out['obj_type'] = 'Position'
    out
  end
end

def generate_agencies_yaml
  out_file = File.join(DATA_DIR, 'agencies.yml')
  agencies = Agency.eager(positions: :person, system_roles: :govt_system,
                          events: %i[people agencies]).map do |agency|
    out = agency.to_hash
    agency['children'] = agency.children.map(&:to_hash)

    out['positions'] = positions_for_output(agency.all_positions)
    out['events'] = events_for_output(agency.all_events)
    out['system_access'] = agency.all_system_roles.map(&:to_hash)
    out['obj_type'] = 'Agency'
    out
  end

  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(agencies, line_width: 150, stringify_names: true, header: false)
    file.write(out_yaml)
  end
end

def generate_aliases_yaml
  out_file = File.join(DATA_DIR, 'aliases.yml')
  out_array = DogeAlias.map do |a|
    out = a.to_hash
    out['events'] = events_for_output(a.events)
    out
  end

  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(out_array, line_width: 150, stringify_names: true, header: false)
    file.write(out_yaml)
  end
end

def generate_pages_yaml
  out_file = File.join(DATA_DIR, 'pages.yml')
  people_hash = {}

  Person.each do |p|
    path = if p.page_slug
             if p.page_slug == 'self'
               "/people/#{p.slug}"
             elsif p.page_slug == 'none'
               'none'
             else
               p.page_slug
             end
           else
             "/people##{p.slug}"
           end

    people_hash[p.name] = { name: p.name, slug: p.slug, path: path, sort_name: p.sort_name }
  end

  agency_hash = {}

  Agency.each do |a|
    path = if a.page_slug
             if a.page_slug == 'self'
               "/agencies/#{a.slug}"
             elsif a.page_slug == 'none'
               'none'
             else
               a.page_slug
             end
           else
             "/agencies##{a.slug}"
           end

    agency_hash[a.id] = { id: a.id, name: a.name, slug: a.slug, path: path }
  end

  out = { people: people_hash, agencies: agency_hash }
  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(out, line_width: 150, stringify_names: true, header: false)
    file.write(out_yaml)
  end
end

def generate_people_yaml
  out_file = File.join(DATA_DIR, 'people.yml')

  out = Person.eager(system_roles: :govt_system).all.map do |p|
    rec = p.to_hash
    rec['positions'] = p.positions.sort_by(&:sort_date).map(&:to_hash)
    rec['events'] = events_for_output(p.events)
    rec['system_access'] = p.system_roles.map(&:to_hash)
    rec['obj_type'] = 'Person'

    if p.positions.any?
      pos = p.positions.first
      rec['start_date'] = pos.start_date
      rec['sort_date'] = pos.sort_date
      rec['start_agency'] = pos.agency_id
    else
      rec['sort_date'] = '2025-01-20'
    end

    rec
  end

  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(out, line_width: 150, stringify_names: true, header: false)
    file.write(out_yaml)
  end
end

def generate_positions_yaml
  out_file = File.join(DATA_DIR, 'positions.yml')
  out = {}

  Position.eager(:person, :doge_alias, :agency).map do |position|
    key = position.id
    out[key] = position.to_hash
    out[key][:person] = position.person.to_hash.merge(obj_type: 'Person') if position.person
    out[key][:alias] = position.doge_alias.to_hash.merge(obj_type: 'Alias') if position.doge_alias
    out[key][:agency] = position.agency.to_hash.merge(obj_type: 'Agency')
    out[key][:agency_ids] = [position.agency.id, position.agency.parent_id].compact
  end

  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(out, line_width: 150, stringify_names: true, header: false)
    file.write(out_yaml)
  end
end

def generate_events_yaml
  out_file = File.join(DATA_DIR, 'events.yml')
  events = Event.eager(:people, :agencies, :doge_aliases)
  out_events = events.map do |e|
    out = e.to_hash
    out['people'] = e.people.map(&:to_hash)
    out['agency_ids'] = e.agencies.map(&:id)
    out['aliases'] = e.doge_aliases.map(&:to_hash)

    out['names_aliases'] = e.people.map { |p| { name: p.name, slug: p.slug, sort_name: p.sort_name } }
    e.doge_aliases.each do |a|
      if a.name
        ap = out['names_aliases'].find { |x| x[:name] == a.name }

        if ap.nil?
          out['names_aliases'].append({ alias: a.id, name: a.name, slug: a.person.slug, sort_name: a.person.sort_name })
        else
          ap['alias'] = a.id
        end
      else
        out['names_aliases'].append({ alias: a.id, sort_name: "ZZZ-#{a.id}" })
      end
    end
    out['names'] = out['names'].sort_by { |x| x['sort_name'] } if out.key? 'names'

    agency_ids = e.agencies.map(&:id)
    parent_ids = e.agencies.map(&:parent_id)
    out['agencies_parents'] = (agency_ids + parent_ids).uniq.compact
    out['obj_type'] = 'Event'

    out
  end

  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(out_events, line_width: 150, stringify_names: true, header: false)
    file.write(out_yaml)
  end
end

def generate_systems_yaml
  out_file = File.join(DATA_DIR, 'systems.yml')
  out = {}

  GovtSystem.eager(system_roles: %i[person doge_alias]).each do |s|
    key = s.id
    out[key] = s.to_hash
    out[key]['roles'] = s.system_roles.map(&:to_hash)
  end

  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(out, line_width: 150, stringify_names: true, header: false)
    file.write(out_yaml)
  end
end

if __FILE__ == $PROGRAM_NAME
  generate_pages_yaml
  generate_aliases_yaml
  generate_agencies_yaml
  generate_people_yaml
  generate_positions_yaml
  generate_events_yaml
  generate_systems_yaml
end
