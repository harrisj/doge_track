# frozen_string_literal: true

require 'date'
require 'yaml'
require 'fileutils'
require_relative 'models'
require 'edtf-humanize'

DATA_DIR = File.join(File.dirname(__FILE__), '..', '..', 'src', '_data')

# def events_for_output(events)
#   events.sort_by(&:sort_date).map do |e|
#     e_out = e.to_hash
#     e_out['agencies'] = e.agencies.map { |a| a.to_hash.slice(:id, :slug, :name, :short_name) }
#     e_out['people'] = e.people.map { |x| x.to_hash.slice(:slug, :name, :sort_name) }

#     e_out['aliases'] = []
#     e.doge_aliases.each do |a|
#       if a.person
#         existing_record = e_out['people'].find { |p| p[:name] == a.name }
#         existing_record[:alias] = a.id
#       else
#         e_out['aliases'].append(a.id)
#       end
#     end

#     e_out
#   end
# end

# def positions_for_output(positions)
#   positions.sort_by(&:sort_date).map do |x|
#     out = x.to_hash
#     out['duration_summary'] = x.duration_summary
#     out['agency'] = { agency_id: x.agency.id, name: x.agency.name, short_name: x.agency.short_name }
#     if x.from_agency
#       out['from_agency'] =
#         { agency_id: x.from_agency.id, name: x.from_agency.name, short_name: x.from_agency.short_name }
#     end
#     out['person'] = x.person.to_hash.merge(obj_type: 'Person') unless x.person.nil?
#     out['alias'] = x.doge_alias.to_hash.merge(obj_type: 'Alias') unless x.doge_alias.nil?
#     out['documents'] = x.documents.map { |d| d.to_hash.merge(url: d.url) }

#     out['obj_type'] = 'Position'
#     out
#   end
# end

def generate_agencies_yaml
  out_file = File.join(DATA_DIR, 'agencies.yml')
  agencies = Agency.map do |agency|
    out = agency.to_hash
    agency['children'] = agency.children.map(&:id)

    out['position_ids'] = agency.all_positions.map(&:id)
    out['event_ids'] = agency.all_events.map(&:id)
    out['system_access'] = agency.all_system_roles.map(&:id)
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
    out['events'] = a.events.map(&:id)
    out
  end

  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(out_array, line_width: 150, stringify_names: true, header: false)
    file.write(out_yaml)
  end
end

def generate_documents_yaml
  out_file = File.join(DATA_DIR, 'documents.yml')
  out_array = Document.map(&:to_hash)

  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(out_array, line_width: 150, stringify_names: true, header: false)
    file.write(out_yaml)
  end
end

def generate_people_yaml
  out_file = File.join(DATA_DIR, 'people.yml')

  out = Person.all.map do |p|
    rec = p.to_hash
    rec['position_ids'] = p.positions.map(&:id) # positions_for_output(p.positions)
    rec['event_ids'] = p.events.map(&:id) # events_for_output(p.events)
    rec['system_access'] = p.system_roles.map(&:id)
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

  out = Position.map do |position|
    p_hash = position.to_hash
    p_hash[:agency] = position.agency.to_hash
    p_hash[:from_agency] = position.from_agency.to_hash unless position.from_agency.nil?
    p_hash[:agency_and_parent] = [position.agency.id, position.agency.parent_id].compact
    p_hash[:documents] = position.documents.map { |d| d.to_hash.merge(url: d.url) }
    p_hash
  end

  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(out, line_width: 150, stringify_names: true, header: false)
    file.write(out_yaml)
  end
end

def generate_events_yaml
  out_file = File.join(DATA_DIR, 'events.yml')

  out_events = Event.all.map do |e|
    out = e.to_hash
    out['names'] = e.people.map(&:name)
    out['agency_ids'] = e.agencies.map(&:id)
    out['alias_ids'] = e.doge_aliases.map(&:to_hash)

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

  GovtSystem.each do |s|
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
  generate_aliases_yaml
  generate_documents_yaml
  generate_agencies_yaml
  generate_people_yaml
  generate_positions_yaml
  generate_events_yaml
  generate_systems_yaml
end
