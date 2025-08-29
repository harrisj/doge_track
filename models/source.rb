# frozen_string_literal: true

require 'sequel'

# Represent a single source
class Source < Sequel::Model
  many_to_one :publisher, key: :pub_id

  many_to_many :events
  many_to_many :positions
  many_to_many :system_roles

  # backward compatibility
  def short_name
    publisher.short_name || 'source'
  end
end
