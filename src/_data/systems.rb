# frozen_string_literal: true

require_relative '../../data/scripts/models'

GovtSystem.eager(system_roles: %i[person doge_alias]).map do |s|
  out = s.to_hash
  out['roles'] = s.system_roles.map(&:to_hash)
  out
end
