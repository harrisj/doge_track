# frozen_string_literal: true

module Grid
  # The block of systems for an agency
  class ProjectSystems < Bridgetown::Component
    def initialize(project:)
      super()
      @project = project
      @systems = project.govt_systems
    end

    def template
      return unless @systems.any?

      by_agency = @systems.reject { |a| a.agency.nil? }.group_by { |s| s.agency.parent_id || s.agency_id }

      html lambda {
        <<~HTML
          <h2 class="data-grid-title">Systems</h2>
          #{html_map(by_agency) do |agency, systems|
              next if agency.nil?

              <<~HTML
                <div>#{render Atoms::AgencyLink.new(agency)}</div>
                <div class="flex flex-col gap-y-3">
                  #{ html_map(systems) do |govt_system|
                       render Grid::SystemRoles.new(govt_system: govt_system, expanded: true)
                     end
                  }
                </div>
              HTML
            end }
        HTML
      }
    end
  end
end
