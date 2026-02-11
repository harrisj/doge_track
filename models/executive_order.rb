# frozen_string_literal: true

require 'sequel'

# Represents an executive order
class ExecutiveOrder < Sequel::Model
  plugin :auto_validations
  many_to_many :agencies

  def linkified_summary
    summary
  end

  def agency_ids
    agencies.map(&:id)
  end
end
