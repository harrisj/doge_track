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

DogeAlias.map do |a|
  out = a.to_hash
  out['events'] = events_for_output(a.events)
  out
end
