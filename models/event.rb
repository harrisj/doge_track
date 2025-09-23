# frozen_string_literal: true

require 'sequel'

# Represents a single event
class Event < Sequel::Model
  plugin :single_table_inheritance, :type

  many_to_many :agencies, graph_join_type: :inner
  many_to_many :doge_aliases
  many_to_many :people, right_key: :name, order: :sort_name
  many_to_one :case, key: :case_no
  many_to_many :sources

  one_to_many :questions
end
