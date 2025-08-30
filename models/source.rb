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

  def agencies
    if @_agencies.nil?
      @_agencies = []
      @_agencies += events.map(&:agencies) if events.any?
      @_agencies += positions.map(&:agency) if positions.any?
      @_agencies += system_roles.map(&:agency) if system_roles.any?
      @_agencies = @_agencies.flatten.compact.uniq
    end

    @_agencies
  end

  def people
    if @_people.nil?
      @_people = []
      @_people += events.map(&:people) if events.any?
      @_people += positions.map(&:person) if positions.any?
      @_people += system_roles.map(&:person) if system_roles.any?
      @_people = @_people.flatten.compact.uniq
    end

    @_people
  end
end
