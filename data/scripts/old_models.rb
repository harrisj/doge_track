# frozen_string_literal: true

require 'edtf'
require 'sequel'

DB_PATH = File.join(File.dirname(__FILE__), '..', 'doge.sqlite')
DB = Sequel.sqlite(DB_PATH)

def humanize_edtf_date(date)
  date = Date.edtf(date.to_s)

  if date.unspecified?
    if date.unspecified?(:day) && !date.unspecified?(:month)
      "~ #{date.strftime('%b %Y')}"
    elsif date.unspecified?(:day) && date.unspecified?(:month)
      "~ #{date.strftime('%Y')}"
    else
      'unknown'
    end
  elsif date.uncertain?
    if date.uncertain?(:day) && !date.uncertain?(:month)
      "~ #{date.strftime('%b %d, %Y')}"
    else
      "~ #{date.strftime('%b %Y')}"
    end
  elsif date.approximate?
    if date.approximate?(:day) && !date.approximate?(:month)
      "~ #{date.strftime('%b %d, %Y')}"
    else
      "~ #{date.strftime('%b %Y')}"
    end
  else
    date.strftime('%b %d, %Y')
  end
end

# Represents a single agency
class Agency < Sequel::Model
  many_to_many :events

  many_to_one :parent, class: self
  one_to_many :children, key: :parent_id, class: self

  one_to_many :details_from, class: :Position, key: :from_agency
  one_to_many :positions

  one_to_many :doge_aliases

  one_to_many :system_roles
  many_to_many :cases, right_key: :case_no, left_key: :agency_id
  many_to_many :executive_orders

  def all_positions
    out = positions
    children.each do |c|
      out += c.positions
    end

    out.sort_by { |x| x.start_date || '2025-01-20' }
  end

  def all_events
    out = events
    children.each do |c|
      out += c.events
    end

    out.each_with_index.sort_by { |e, idx| [Date.edtf(e[:date].to_s), idx] }.map(&:first)
  end

  def all_system_roles
    out = system_roles
    children.each do |c|
      out += c.system_roles
    end

    out.sort_by { |x| x.date_granted || '2025-01-20' }
  end
end

# For documents
class Document < Sequel::Model
  many_to_one :person
  many_to_many :positions

  def url
    "/documents/#{file}"
  end
end

# Represents an alias
class DogeAlias < Sequel::Model
  many_to_one :agency
  many_to_one :person, key: :name
  one_to_many :positions

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

# # Represents an executive order
# class ExecutiveOrder < Sequel::Model
#   many_to_many :agencies
# end

# Represents a single DOGE member
class Person < Sequel::Model
  one_to_many :doge_aliases, key: :name
  many_to_many :events, left_key: :name, order: :sort_date
  one_to_many :positions, key: :name, order: :sort_date
  one_to_many :system_roles, key: :name, order: :date_granted
end

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

  def duration_summary
    return 'dates unknown' if start_date.nil? && end_date.nil?

    if !start_date.nil? && end_date.nil?
      "from #{display_start_date}"
    elsif start_date.nil? && !end_date.nil?
      "before #{display_end_date}"
    elsif start_date == end_date
      display_start_date
    else
      "#{display_start_date} to #{display_end_date}"
    end
  end

  def display_start_date
    return 'unknown' if start_date.nil?

    humanize_edtf_date(start_date)
  end

  def display_end_date
    return 'unknown' if end_date.nil?

    humanize_edtf_date(end_date)
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

class Question < Sequel::Model
end
