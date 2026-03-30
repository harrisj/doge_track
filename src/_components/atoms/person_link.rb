# frozen_string_literal: true

module Atoms
  # A link to a person's page
  class PersonLink < Bridgetown::Component
    def initialize(person: nil, name: nil, display: nil)
      super()
      @person = person.nil? ? Person.with_pk!(name) : person

      raise 'You must provide a person or a name' if @person.nil?

      @display = display
    end

    def display_name
      @display || @person.name
    end

    def template
      html lambda {
        <<~HTML
          <a class="link-hover" href="#{text -> { @person.page_url }}">#{text -> { display_name }}</a>
        HTML
      }
    end
  end
end
