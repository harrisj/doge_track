# frozen_string_literal: true

require 'sequel'

# Represent a single publisher
class Publisher < Sequel::Model
  plugin :auto_validations

  one_to_many :sources
end
