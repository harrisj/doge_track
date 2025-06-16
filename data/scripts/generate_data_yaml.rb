# frozen_string_literal: true

require 'date'
require 'yaml'
require 'fileutils'
require_relative 'models'
require 'edtf-humanize'
require 'kramdown'

DATA_DIR = File.join(File.dirname(__FILE__), '..', '..', 'src', '_data')

def person_url(person)
  return person.custom_path unless person.custom_path.nil?

  case person.category
  when 'wrecker'
    "/wreckers/other##{person.slug}"
  when 'enabler'
    "/people/enabler-staff##{person.slug}"
  when 'support'
    "/people/support-team##{person.slug}"
  when 'unknown'
    "/people/unknowns##{person.slug}"
  else
    "/all/people##{person.slug}"
  end
end

def agency_url(agency)
  if agency.page_slug == 'none'
    nil
  elsif agency.page_slug == 'self'
    "/agencies/#{agency.slug}"
  elsif agency.page_slug == 'other-majors' # FIXME
    "/agencies/#{agency.slug}##{agency.slug}"
  elsif agency.page_slug
    "/agencies/#{agency.page_slug}"
  else
    "/agencies##{agency.slug}"
  end
end

def internal_link(url, display)
  "<a class=\"link-hover\" href=\"#{url}\">#{display}</a>"
end

def linkify_text(text)
  out = text.dup

  Person.each do |person|
    out.gsub!(/\b#{person.name}\b/, internal_link(person_url(person), person.name))
  end

  Agency.each do |agency|
    out.gsub!(/\b#{agency.id}\b/, internal_link(agency_url(agency), agency.id)) if agency.id =~ /^[A-Z]+$/
    out.gsub!(/\b#{agency.name}\b/, internal_link(agency_url(agency), agency.name))
  end

  Kramdown::Document.new(out).to_html.gsub(%r{</?p>}, '')
end

def generate_agencies_yaml
  out_file = File.join(DATA_DIR, 'agencies.yml')
  agencies = Agency.map do |agency|
    out = agency.to_hash
    agency['path'] = agency_url(agency)
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
    # out['events'] = a.events.map(&:id)
    out['position_ids'] = a.positions.map(&:id)
    out['event_ids'] = a.events.map(&:id)
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
    rec['path'] = person_url(p)
    rec['position_ids'] = p.positions.map(&:id) # positions_for_output(p.positions)
    rec['event_ids'] = p.events.map(&:id) # events_for_output(p.events)
    rec['system_access'] = p.system_roles.map(&:id)
    rec['obj_type'] = 'Person'
    rec['linkified_blurb'] = linkify_text(p.blurb) unless p.blurb.nil?

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

  # FIXME: Figure out why my hydration isn't working for positions
  out = Position.map do |position|
    p_hash = position.to_hash
    p_hash[:sort_date] ||= p_hash[:start_date]
    p_hash[:agency] = position.agency.to_hash.merge(obj_type: 'Agency', path: agency_url(position.agency))
    unless position.from_agency.nil?
      p_hash[:from_agency] =
        position.from_agency.to_hash.merge(obj_type: 'Agency', path: agency_url(position.from_agency))
    end
    p_hash[:agency_and_parent] = [position.agency.id, position.agency.parent_id].compact
    p_hash[:documents] = position.documents.map { |d| d.to_hash.merge(url: d.url) }
    p_hash
  end

  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(out, line_width: 150, stringify_names: true, header: false)
    file.write(out_yaml)
  end
end

def generate_exec_orders_yaml
  out_file = File.join(DATA_DIR, 'executive_orders.yml')
  out_array = ExecutiveOrder.map do |e|
    out = e.to_hash
    out['linkified_summary'] = linkify_text(e.summary)
    out['agency_ids'] = e.agencies.map(&:id)
    out
  end

  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(out_array, line_width: 150, stringify_names: true, header: false)
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

    out['names_aliases'] = e.people.map do |p|
      { name: p.name, slug: p.slug, sort_name: p.sort_name, category: p.category }
    end
    e.doge_aliases.each do |a|
      if a.name
        ap = out['names_aliases'].find { |x| x[:name] == a.name }

        if ap.nil?
          out['names_aliases'].append({ alias: a.id, name: a.name, slug: a.person.slug, sort_name: a.person.sort_name,
                                        category: a.person.category })
        else
          ap['alias'] = a.id
        end
      else
        out['names_aliases'].append({ alias: a.id, sort_name: "ZZZ-#{a.id}", category: 'alias' })
      end
    end

    agency_ids = e.agencies.map(&:id)
    parent_ids = e.agencies.map(&:parent_id)
    out['agencies_parents'] = (agency_ids + parent_ids).uniq.compact
    out['obj_type'] = 'Event'
    out['linkified_text'] = linkify_text(e.text)
    out
  end

  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(out_events, line_width: 150, stringify_names: true, header: false)
    file.write(out_yaml)
  end
end

def generate_systems_yaml
  out_file = File.join(DATA_DIR, 'systems.yml')

  out = GovtSystem.map do |s|
    sys_out = s.to_hash
    sys_out['all_agency_ids'] = ([s.agency_id] + s.system_roles.map(&:agency_id)).compact.uniq
    sys_out['all_names'] = s.system_roles.map(&:name).compact
    sys_out['access_ids'] = s.system_roles.map(&:id).compact
    sys_out
  end

  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(out, line_width: 150, stringify_names: true, header: false)
    file.write(out_yaml)
  end
end

def generate_roles_yaml
  out_file = File.join(DATA_DIR, 'system_roles.yml')

  out = SystemRole.map do |s|
    sys_out = s.to_hash
    sys_out
  end

  File.open(out_file, 'w') do |file|
    out_yaml = YAML.dump(out, line_width: 150, stringify_names: true, header: false)
    file.write(out_yaml)
  end
end

def generate_questions_yaml
  out_file = File.join(DATA_DIR, 'questions.yml')

  out = Question.map(&:to_hash)

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
  generate_exec_orders_yaml
  generate_systems_yaml
  generate_roles_yaml
  generate_questions_yaml
end
