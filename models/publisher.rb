# frozen_string_literal: true

require 'sequel'

# Represent a single publisher
class Publisher < Sequel::Model
  one_to_many :sources
end
