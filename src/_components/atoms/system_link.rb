# frozen_string_literal: true

module Atoms
  # A link to an agency's page
  class SystemLink < Bridgetown::Component
    def initialize(govt_system, raise_miss: true)
      super()

      if govt_system.nil? && raise_miss
        raise ArgumentError,
              'AliasLink: you must provide a GovtSystem object or an ID or acronym'
      end

      if govt_system.is_a?(GovtSystem)
        @govt_system = govt_system
      elsif govt_system.is_a? String
        @govt_system = GovtSystem[govt_system] || GovtSystem.where(acronym: govt_system).first

        if @govt_system.nil? && raise_miss
          raise Sequel::NoMatchingRow,
                "Unable to find govt_system with ID #{govt_system}"
        end
      else
        @govt_system = nil
      end
    end

    def display_name
      @govt_system.acronym || @govt_system.name
    end

    def template
      return text -> { '' } if @govt_system.nil?

      html lambda {
        <<~HTML.chomp
          <a class="link-hover" href="/all/systems##{text -> { @govt_system.id }}" title="#{text -> { @govt_system.name }}">#{text -> { display_name }}</a>
        HTML
      }
    end
  end
end
