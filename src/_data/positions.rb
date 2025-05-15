# frozen_string_literal: true

require_relative '../../data/scripts/models'

Position.eager(:person, :doge_alias, :agency).map do |position|
  out = position.to_hash
  position[:person] = position.person.to_hash if position.person
  position[:alias] = position.doge_alias.to_hash if position.doge_alias
  position[:agency] = position.agency.to_hash
  position[:agency_ids] = [position.agency.id, position.agency.parent_id].compact
  out
end
