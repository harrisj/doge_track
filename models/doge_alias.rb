# frozen_string_literal: true

require 'sequel'

# Represents an alias
class DogeAlias < Sequel::Model
  plugin :auto_validations

  many_to_one :agency
  many_to_one :person, key: :name
  one_to_many :positions

  many_to_many :events
  many_to_many :sources
end
