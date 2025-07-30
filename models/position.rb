# frozen_string_literal: true

require 'sequel'

# Represents a single detailing agreement between two agencies
class Position < Sequel::Model
  many_to_one :doge_alias
  many_to_one :person, key: :name, primary_key: :name
  many_to_one :from_agency, class: :Agency, key: :from_agency_id
  many_to_one :agency
  many_to_many :documents

  def detail?
    type == 'detailed'
  end
end
