# frozen_string_literal: true

require_relative '../../data/scripts/models'

def events_for_output(events)
  events.map do |e|
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
  positions.map do |x|
    out = x.to_hash
    out['duration_summary'] = x.duration_summary
    out['agency'] = { agency_id: x.agency.id, name: x.agency.name, short_name: x.agency.short_name }
    if x.from_agency
      out['from_agency'] =
        { agency_id: x.from_agency.id, name: x.from_agency.name, short_name: x.from_agency.short_name }
    end
    out['person'] = x.person.to_hash unless x.person.nil?
    out['alias'] = x.doge_alias.to_hash unless x.doge_alias.nil?
    out
  end
end

Agency.eager(positions: :person, system_roles: :govt_system,
             events: %i[people agencies]).where(parent_id: nil).map do |agency|
  out = agency.to_hash
  agency['children'] = agency.children.map(&:to_hash)

  out['positions'] = positions_for_output(agency.all_positions)
  out['events'] = events_for_output(agency.all_events)
  out['system_access'] = agency.all_system_roles.map(&:to_hash)
  out
end
