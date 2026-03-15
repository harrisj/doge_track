# frozen_string_literal: true

require 'sequel'
require 'edtf'

# Represents a single detailing agreement between two agencies
class Position < Sequel::Model
  extend EdtfLoader

  plugin :auto_validations

  edtf_field :start_date, :end_date, :nte_date

  many_to_one :doge_alias
  many_to_one :person, key: :name, primary_key: :name
  many_to_one :agency, graph_join_type: :inner
  many_to_one :from_agency, class: :Agency, key: :from_agency_id, graph_join_type: :left_outer
  many_to_many :documents
  many_to_many :sources
  many_to_many :project

  def detail?
    type == 'detailed'
  end

  def internal_xfer?
    type == 'internal'
  end

  def sort_name
    if person
      person.sort_name
    else
      "ZZZZZZ-#{doge_alias_id}"
    end
  end

  def sort_parent_agency
    agency.parent || agency
  end
end
