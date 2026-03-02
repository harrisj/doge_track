# frozen_string_literal: true

require 'sequel'

# Represents a single project
class Project < Sequel::Model
  plugin :auto_validations

  many_to_many :events, order: :date
  many_to_many :govt_systems, order: :name
  many_to_many :positions, order: :sort_date
end
