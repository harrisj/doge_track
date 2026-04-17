# frozen_string_literal: true

require 'sequel'

# Represent System Access by a single DOGE user
class SystemRole < Sequel::Model
  plugin :auto_validations

  many_to_one :govt_system
  many_to_one :agency
  many_to_one :person, key: :name
  many_to_one :doge_alias
  many_to_many :sources

  def agency
    self[:agency] || govt_system&.agency
  end

  # Query helpers
  def self.granted_in_year_month(year, month)
    SystemRole.eager(:govt_system, :person,
                     :sources).where(Sequel.like(:date_granted,
                                                 "#{year}-#{format('%02d', month)}%")).order_by(:date_granted)
  end

  def self.revoked_in_year_month(year, month)
    SystemRole.eager(:govt_system, :person,
                     :sources).where(Sequel.like(:date_revoked,
                                                 "#{year}-#{format('%02d', month)}%")).order_by(:date_revoked)
  end
end
