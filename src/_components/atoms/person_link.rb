# frozen_string_literal: true

module Atoms
  # A link to a person's page
  class PersonLink < Bridgetown::Component
    def initialize(person, display: nil, raise_miss: true)
      super()
      @display = display
      @raise_miss = raise_miss

      if person.is_a? Person
        @person = person
        @name = person.name
      elsif person.is_a? String
        @name = person
        @person = Person[person]

        raise Sequel::NoMatchingRow, "Unable to find person with name #{person.inspect}" if @person.nil? && @raise_miss
      else
        @person = nil
        @name = ''
      end

      raise "You must provide a person or a name to PersonLink: #{person.inspect}" if @raise_miss && @person.nil?
    end

    def display_name
      @display || @name
    end

    def template
      if @person.nil?
        # No person record found, return input arg as text
        return text -> { display_name }
      end

      html lambda {
        <<~HTML.chomp
          <a class="link-hover" href="#{text -> { @person.page_url }}">#{text -> { display_name }}</a>
        HTML
      }
    end
  end
end
