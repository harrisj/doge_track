# frozen_string_literal: true

require 'sequel'

# FIXME
class Question < Sequel::Model
  many_to_one :event
  many_to_one :agency
  many_to_one :person, key: :name
end
