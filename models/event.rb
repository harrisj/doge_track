# frozen_string_literal: true

require 'sequel'

# Represents a single event
class Event < Sequel::Model
  extend EdtfLoader

  plugin :auto_validations

  edtf_field :date

  many_to_many :agencies, graph_join_type: :inner
  many_to_many :doge_aliases
  many_to_many :people, right_key: :name, order: :sort_name
  many_to_one :case, key: :case_no
  many_to_many :sources
  many_to_many :projects

  one_to_many :questions

  # FIXME
  def sort_date
    date
  end

  # Query helpers
  def self.for_year_month(year, month)
    Event.where(Sequel.like(:date, "#{year}-#{format('%02d', month)}%")).order_by(&:date)
  end

  # Max date
  def self.max_date
    Date.parse(Event.max(:date))
  end
end
