# frozen_string_literal: true

require 'sequel'
require 'edtf'

# Represents a single detailing agreement between two agencies
class Position < Sequel::Model
  many_to_one :doge_alias
  many_to_one :person, key: :name, primary_key: :name
  many_to_one :from_agency, class: :Agency, key: :from_agency_id
  many_to_one :agency, graph_join_type: :inner
  many_to_many :documents
  many_to_many :sources

  def detail?
    type == 'detailed'
  end

  # Backward compatibility
  def source
    sources.first&.url
  end

  def source_name
    sources.first&.publisher&.short_name
  end

  def chart_start_date
    if start_date
      Date.edtf(start_date).to_s
    elsif sort_date
      sort_date.to_s
    else
      ''
    end
  end

  def chart_end_date
    if end_date
      Date.edtf(end_date).to_s
    else
      Date.today.to_s
    end
  end
end
