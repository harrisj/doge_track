# frozen_string_literal: true

require 'date'
require 'sequel'
require 'edtf'
require_relative 'edtf_loader'
require_relative 'dt_utils'

# Represents a single DOGE member
class Person < Sequel::Model
  extend EdtfLoader

  plugin :auto_validations

  edtf_field :start_date, :govt_exit_date

  one_to_many :doge_aliases, key: :name
  many_to_many :events, left_key: :name, order: :sort_date
  one_to_many :positions, key: :name, order: :sort_date, eager_graph: %i[agency from_agency]
  one_to_many :system_roles, key: :name, order: :date_granted, eager_graph: [:govt_system]
  one_to_many :affiliations, key: :name, eager_graph: [:entity]

  def all_events
    event_ids = Event.select(Sequel[:events][:id]).association_join(:people).where({ Sequel[:people][:name] => name })
    Event.eager_graph(:people, :agencies, :doge_aliases).where({ Sequel[:events][:id] => event_ids }).order(:date).all
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

    positions.first.start_date
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

  # Interval helper methods
  def min_date_interval_to_date(field = :govt_exit_date)
    field_value = values[field]
    DtUtils.parse_interval(field_value)&.first
  end

  def max_date_interval_to_date(field = :govt_exit_date)
    field_value = values[field]
    DtUtils.parse_interval(field_value)&.last
  end

  # Total number of distinct calendar months across all positions.
  # Uses the union of position month-keys so gaps (e.g. a person who left
  # and returned) are not counted toward service time.
  # Returns nil when there is no position start date to anchor on.
  def months_in_govt
    return unless positions.any? && start_date

    key_format = '%Y-%m'
    month_keys = Set.new

    positions.each do |pos|
      next unless pos.start_date

      start_date = pos.start_date
      start_date = pos.min_interval_to_date(:start_date) if start_date.is_a?(EDTF::Interval)
      month_keys.add(start_date.strftime(key_format))
      end_date = pos.end_date
      end_date = pos.max_date_interval_to_date(:end_date) if end_date.is_a?(EDTF::Interval)
      next unless end_date

      month_keys.merge((start_date..end_date).map { |x| x.strftime(key_format) }.uniq)
    end

    month_keys.size
  end
end
