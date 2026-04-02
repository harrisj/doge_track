# frozen_string_literal: true

module Atoms
  # A link to an agency's page
  class AgencyLink < Bridgetown::Component
    def initialize(agency = nil, display: nil, raise_miss: true)
      super()

      raise ArgumentError, 'AgencyLink: you must provide an agency or a name' if agency.nil? && raise_miss

      if agency.is_a?(Agency)
        @agency = agency
      elsif agency.is_a? String
        @agency = Agency[agency]

        raise Sequel::NoMatchingRow, "Unable to find agency with ID #{agency}" if @agency.nil? && raise_miss
      else
        @agency = nil
      end

      @display = display
    end

    def display_name
      @display || @agency&.short_name || @agency
    end

    def template
      return text -> { '' } if @agency.nil?

      html lambda {
        <<~HTML
          <a class="link-hover" href="#{text -> { @agency.page_url }}">#{text -> { display_name }}</a>
        HTML
      }
    end
  end
end
