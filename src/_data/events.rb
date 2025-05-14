# frozen_string_literal: true

require_relative '../../data/scripts/models'

events = Event.eager(:people, :agencies, :doge_aliases)

events.map do |e|
  out = e.to_hash
  out['people'] = e.people.map(&:to_hash)
  out['agencies'] = e.agencies.map(&:to_hash)
  out['aliases'] = e.doge_aliases.map(&:to_hash)

  agency_ids = e.agencies.map(&:id)
  parent_ids = e.agencies.map(&:parent_id)
  out['agency_ids'] = (agency_ids + parent_ids).uniq

  out
end
