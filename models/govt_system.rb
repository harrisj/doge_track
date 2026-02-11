# frozen_string_literal: true

require 'sequel'

# Represents a system
class GovtSystem < Sequel::Model
  plugin :auto_validations

  many_to_one :agency
  one_to_many :system_roles
  # one_to_many :serves, class: :Agency, key: :agency_id
end
