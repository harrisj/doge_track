# frozen_string_literal: true

require 'sequel'

# Represent System Access by a single DOGE user
class SystemRole < Sequel::Model
  many_to_one :govt_system
  many_to_one :agency
  many_to_one :person, key: :name
  many_to_one :doge_alias
  many_to_many :sources

  # Backward compatibility
  def source
    sources.first&.url
  end

  def source_name
    sources.first&.publisher&.short_name
  end
end
