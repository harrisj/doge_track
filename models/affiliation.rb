# frozen_string_literal: true

require_relative 'edtf_loader'

# A class to represent affiliations
class Affiliation < Sequel::Model
  extend EdtfLoader

  plugin :auto_validations
  edtf_field :start_date, :end_date

  many_to_one :person, key: :name, primary_key: :name
  many_to_one :entity
  many_to_many :sources
end
