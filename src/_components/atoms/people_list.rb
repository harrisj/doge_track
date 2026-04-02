# frozen_string_literal: true

module Atoms
  # A list of multiple people or aliases rendered in a compact style
  class PeopleList < CompactList
    def initialize(people, raise_miss: true)
      super(people)
      @raise_miss = raise_miss

      unless people.is_a?(Array) && people.all? do |item|
        item.is_a?(Person) || item.is_a?(DogeAlias) || item.is_a?(String)
      end
        raise ArgumentError,
              'Agencies argument must be an array of People or Alias objects or IDs'
      end
    end

    def render_item(item)
      render Atoms::PersonOrAliasLink.new(item, raise_miss: @raise_miss)
    end
  end
end
