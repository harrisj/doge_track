# frozen_string_literal: true

require 'sequel'

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

  # REMOVE LATER
  def obj_type
    'Agency'
  end

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
