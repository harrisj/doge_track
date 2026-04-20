# frozen_string_literal: true

module Grid
  # The block of systems for an agency
  class AgencySystems < Bridgetown::Component
    def initialize(agency:)
      super()
      @agency = agency
      @systems = agency.all_systems
    end

    def template
      return unless @systems.any?

      html lambda {
        <<~HTML
          <h2 class="data-grid-title">Systems</h2>
          #{html_map(@systems) do |govt_system|
              <<~HTML
                <div id="#{text -> { govt_system.id }}">#{render Atoms::SystemLink.new(govt_system)}</div>
                <div>#{render Grid::SystemRoles.new(govt_system: govt_system)}</div>
              HTML
            end }
        HTML
      }
    end
  end
end
