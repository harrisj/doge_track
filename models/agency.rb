# frozen_string_literal: true

require 'sequel'

# Represents a single agency
class Agency < Sequel::Model
  plugin :auto_validations

  many_to_many :events

  many_to_one :parent, class: self
  one_to_many :children, key: :parent_id, class: self

  one_to_many :details_from, class: :Position, key: :from_agency_id
  one_to_many :positions, eager_graph: [:agency, :from_agency, :person, :doge_alias, { sources: :publisher }]

  one_to_many :doge_aliases

  one_to_many :system_roles
  many_to_many :cases, right_key: :case_no, left_key: :agency_id
  many_to_many :executive_orders

  def roles_by_system
    if system_roles.any?
      system_roles.group_by(&:govt_system)
    else
      []
    end
  end

  def all_agency_ids
    [id] + children.map(&:id)
  end

  def all_positions(internal_xfers: false)
    unless @all_positions
      position_ids = Position.select(Sequel[:positions][:id])
                             .association_join(:agency)
                             .filter({ Sequel[:agency][:id] => id })
                             .or({ Sequel[:agency][:parent_id] => id })

      position_ids = position_ids.exclude(type: 'internal') unless internal_xfers

      @all_positions = Position
                       .eager_graph(:person, :agency, :from_agency, :doge_alias, { sources: :publisher })
                       .where({ Sequel[:positions][:id] => position_ids })
                       .all
                       .sort_by { |x| x.start_date || '2025-01-20' }
    end

    @all_positions
  end

  def all_positions_and_details_out(internal_xfers: false)
    unless @all_positions_details
      position_ids = Position.select(Sequel[:positions][:id])
                             .association_join(:agency)
                             .association_left_join(:from_agency)
                             .filter({ Sequel[:agency][:id] => id })
                             .or({ Sequel[:agency][:parent_id] => id })
                             .or({ Sequel[:from_agency][:id] => id })
                             .or({ Sequel[:from_agency][:parent_id] => id })

      position_ids = position_ids.exclude(type: 'internal') unless internal_xfers

      @all_positions_details = Position
                               .eager_graph(:person, :agency, :from_agency, :doge_alias, { sources: :publisher })
                               .where({ Sequel[:positions][:id] => position_ids })
                               .all
                               .sort_by { |x| x.start_date || '2025-01-20' }
    end

    @all_positions_details
  end

  def all_events
    event_ids = Event.select(Sequel[:events][:id])
                     .association_join(:agencies)
                     .filter({ Sequel[:agencies][:id] => id })
                     .or({ Sequel[:agencies][:parent_id] => id })
    Event.eager_graph(:people, :doge_aliases, :agencies,
                      { sources: :publisher }).where({ Sequel[:events][:id] => event_ids }).order(:date).all
  end

  def all_systems
    ids = all_agency_ids
    GovtSystem.eager_graph(system_roles: { sources: :publisher })
              .where({ Sequel[:system_roles][:agency_id] => ids })
              .order(Sequel[:govt_systems][:name]).all
  end

  def page_url
    if page_slug == 'none'
      nil
    elsif page_slug == 'self'
      "/agencies/#{slug}"
    elsif page_slug == 'other-majors' # FIXME
      "/agencies/#{slug}##{slug}"
    elsif page_slug
      "/agencies/#{page_slug}"
    else
      "/agencies##{slug}"
    end
  end
end
