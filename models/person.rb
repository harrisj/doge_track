# frozen_string_literal: true

require 'date'
require 'sequel'
require 'edtf'

# Represents a single DOGE member
class Person < Sequel::Model
  plugin :auto_validations

  one_to_many :doge_aliases, key: :name
  many_to_many :events, left_key: :name, order: :sort_date
  one_to_many :positions, key: :name, order: :sort_date, eager_graph: %i[agency from_agency]
  one_to_many :system_roles, key: :name, order: :date_granted, eager_graph: [:govt_system]

  def all_events
    event_ids = Event.select(Sequel[:events][:id]).association_join(:people).where({ Sequel[:people][:name] => name })
    Event.eager_graph(:people, :agencies, :doge_aliases).where({ Sequel[:events][:id] => event_ids }).order(:date).all
  end

  def category
    if positions.any?
      positions.first.category
    else
      'adjacent'
    end
  end

  def first_agency
    positions.first.agency if positions.any?
  end

  def page_url
    return custom_path unless custom_path.nil?

    "/names/#{slug}"
  end

  def start_date
    return unless positions.any?

    Date.edtf(positions.first.start_date)
  end

  def sort_date
    if positions.any?
      positions.first.sort_date
    else
      '2025-01-20'
    end
  end

  def first_agency_id
    return unless positions.any?

    positions.first.agency_id
  end
end
