# frozen_string_literal: true

require 'sequel'

# Represent System Access by a single DOGE user
class SystemRole < Sequel::Model
  many_to_one :govt_system
  many_to_one :agency
  many_to_one :person, key: :name
  many_to_one :doge_alias
end
