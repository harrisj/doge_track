# frozen_string_literal: true

require 'sequel'

# Represents a single project
class Project < Sequel::Model
  plugin :auto_validations

  many_to_many :events
  many_to_many :systems
  many_to_many :positions
end
