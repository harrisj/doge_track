# frozen_string_literal: true

require 'sequel'

# Represents an executive order
class ExecutiveOrder < Sequel::Model
  plugin :auto_validations
  many_to_many :agencies

  def page_url
    "/projects/exec-orders/#eo-#{id}"
  end

  def linkified_summary
    summary
  end

  def self.in_year_month(year, month)
    ExecutiveOrder.where(Sequel.like(:date, "#{year}-#{format('%02d', month)}%")).order_by(&:date)
  end

  def agency_ids
    agencies.map(&:id)
  end
end
