# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require_relative 'models'

OUTPUT_DIR = File.join(File.dirname(__FILE__), '..', '..', 'src', '_data', 'doge')

def events_for_output(events)
  events.map do |e|
    e_out = e.to_hash
    e_out['agencies'] = e.agencies.map { |a| a.to_hash.slice(:id, :slug, :name) }
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

def roles_for_output(roles)
  roles.map do |r|
    e_out = r.govt_system.to_hash
    e_out['access'] = r.to_hash
    e_out
  end
end

def generate_agencies_yaml
  output_dir = File.join(OUTPUT_DIR, 'agencies')
  FileUtils.mkdir_p(output_dir)

  Agency.all.each do |agency|
    out = agency.to_hash
    out['events'] = events_for_output(agency.events)

    output_path = File.join(output_dir, "#{agency.slug}.yaml")
    File.open(output_path, 'w') do |file|
      file.write(YAML.dump(out, line_width: 100, stringify_names: true, header: false))
    end
  end
end

def generate_people_yaml
  output_dir = File.join(OUTPUT_DIR, 'people')
  FileUtils.mkdir_p(output_dir)

  Person.eager_graph(:events, positions: :agency, system_roles: :govt_system).all.each do |p|
    out = {
      'person': p.to_hash,
      'positions': p.positions.map(&:to_hash),
      'events': events_for_output(p.events),
      'systems': roles_for_output(p.system_roles)
    }

    File.open(File.join(output_dir, "#{p.slug}.yaml"), 'w') do |file|
      file.write(YAML.dump(out, line_width: 100, stringify_names: true, header: false))
    end
  end
end

def generate_alias_yaml
  FileUtils.mkdir_p(OUTPUT_DIR)
  output_file = File.join(OUTPUT_DIR, 'aliases.yaml')

  out = {}
  DogeAlias.each do |a|
    out[a.id] = a.to_hash
    out[a.id]['events'] = events_for_output(a.events)
  end

  File.open(output_file, 'w') do |file|
    file.write(YAML.dump(out, line_width: 100, stringify_names: true, header: false))
  end
end

def generate_people_by_category
  output_path = File.join(OUTPUT_DIR, 'people_by_category.yaml')
  out = {}

  Person.all.each do |p|
    out[p.category] ||= []
    out[p.category].append({ slug: p.slug, own_page: p.own_page, name: p.name })
  end

  File.open(output_path, 'w') do |file|
    file.write(YAML.dump(out, line_width: 100, stringify_names: true, header: false))
  end
end

if __FILE__ == $PROGRAM_NAME
  generate_agencies_yaml
  generate_people_yaml
  generate_alias_yaml
  generate_people_by_category
end
