# frozen_string_literal: true

# Represents a single Entity
class Entity < Sequel::Model
  plugin :auto_validations

  one_to_many :affiliations
end
