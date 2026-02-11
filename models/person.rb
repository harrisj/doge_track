# frozen_string_literal: true

require 'sequel'

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

  def page_url
    return custom_path unless custom_path.nil?

    case category
    when 'wrecker'
      "/wreckers/other##{slug}"
    when 'enabler'
      "/people/enabler-staff##{slug}"
    when 'support'
      "/people/support-team##{slug}"
    when 'booster', 'leadership'
      "/people/leaders##{slug}"
    when 'unknown'
      "/people/unknowns##{slug}"
    else
      "/all/people##{slug}"
    end
  end

  def start_date
    return unless positions.any?

    positions.first.start_date
  end

  def sort_date
    if positions.any?
      positions.first.sort_date
    else
      '2025-01-20'
    end
  end

  def start_agency
    return unless positions.any?

    positions.first.agency_id
  end
end
