# frozen_string_literal: true

module Atoms
  # A link to a person's page
  class PersonOrAliasLink < Bridgetown::Component
    def initialize(thing = nil, display: nil, raise_miss: true)
      super()
      @display = display
      @thing = thing

      if thing.is_a? Person
        @person = thing
      elsif thing.is_a? DogeAlias
        @alias = thing
      elsif thing.is_a? String
        @person = Person[thing]
        @alias = DogeAlias[thing]

        if @person.nil? && @alias.nil? && raise_miss
          raise Sequel::NoMatchingRow,
                "Unable to find person or alias with identifier #{thing}"
        end
      elsif raise_miss
        raise ArgumentError, 'You must pass in an Person, DogeAlias or an ID for either'
      end
    end

    def display_name
      @display || @person&.name || @alias&.name || @thing
    end

    def template
      if @person
        render Atoms::PersonLink.new(@person, display: @display)
      elsif @alias
        render Atoms::AliasLink.new(@alias, display: @display)
      else
        # No person or alias record found, return input arg as text
        text -> { display_name }
      end
    end
  end
end
