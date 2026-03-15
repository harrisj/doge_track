# frozen_string_literal: true

# A class to represent affiliations
class Affiliation < Sequel::Model
  plugin :auto_validations

  many_to_one :person, key: :name, primary_key: :name
  many_to_one :entit
  many_to_many :sources
end
