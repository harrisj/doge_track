# frozen_string_literal: true

module Atoms
  # A link to an agency's page
  class AgencyLink < Bridgetown::Component
    def initialize(agency: nil, id: nil, display: nil)
      super()
      @agency = agency.nil? ? Agency.with_pk!(id) : agency

      raise 'You must provide an agency or a name' if @agency.nil?
      raise 'Pass an Agency object in with the agency argument' unless @agency.is_a? Agency

      @display = display
    end

    def display_name
      @display || @agency.short_name
    end

    def template
      html lambda {
        <<~HTML
          <a class="link-hover" href="#{text -> { @agency.page_url }}">#{text -> { display_name }}</a>
        HTML
      }
    end
  end
end
