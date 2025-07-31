# frozen_string_literal: true

require 'sequel'

# Represents an alias
class DogeAlias < Sequel::Model
  many_to_one :agency
  many_to_one :person, key: :name
  one_to_many :positions

  many_to_many :events

  def category
    if name.blank?
      'unknown'
    else
      person.category
    end
  end
end
