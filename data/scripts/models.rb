# frozen_string_literal: true

require 'sequel'

DB_PATH = File.join(File.dirname(__FILE__), '..', 'doge.sqlite')
DB = Sequel.sqlite(DB_PATH)

# Represents a single agency
class Agency < Sequel::Model
  many_to_many :events
  many_to_many :child_events, class: :Event, key: :parent_id

  many_to_one :parent, class: self
  one_to_many :children, key: :parent_id, class: self

  one_to_many :details_from, class: :Position, key: :from_agency
  one_to_many :positions

  one_to_many :doge_aliases

  one_to_many :system_roles
  many_to_many :cases, right_key: :case_no, left_key: :agency_id
end

# Represents an alias
class DogeAlias < Sequel::Model
  many_to_one :agency
  many_to_one :person, key: :name

  many_to_many :events
end

# Represents a court case
class Case < Sequel::Model
  one_to_many :events, key: :case_no
  many_to_many :agencies, left_key: :case_no, right_key: :agency_id
end

# Represents a system
class GovtSystem < Sequel::Model
  many_to_one :agency
  one_to_many :system_roles
  # one_to_many :serves, class: :Agency, key: :agency_id
end

# Represent System Access by a single DOGE user
class SystemRole < Sequel::Model
  many_to_one :govt_system
  many_to_one :agency
  many_to_one :person, key: :name
  many_to_one :doge_alias
end

# Represents a single DOGE member
class Person < Sequel::Model
  one_to_many :doge_aliases, key: :name
  many_to_many :events, left_key: :name, order: :sort_date
  one_to_many :positions, key: :name, order: :start_date
  one_to_many :system_roles, key: :name, order: :date_granted
end

# Represents a single detailing agreement between two agencies
class Position < Sequel::Model
  many_to_one :doge_alias
  many_to_one :person, key: :name, primary_key: :name
  many_to_one :from_agency, class: :Agency, key: :from_agency_id
  many_to_one :agency

  def detail?
    type == 'detailed'
  end
end

# Represents a single event
class Event < Sequel::Model
  plugin :single_table_inheritance, :type

  many_to_many :agencies
  many_to_many :doge_aliases
  many_to_many :people, right_key: :name, order: :sort_name
  many_to_one :case, key: :case_no
end
