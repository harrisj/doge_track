# frozen_string_literal: true

module MonthGrid
  # A representation of the start positions
  class ClusterSystemAccess < Bridgetown::Component
    def initialize(grants:, revokes:)
      super()
      @grants = grants
      @revokes = revokes
    end

    def grants_section
      by_agency = @grants.group_by { |g| [g.agency_id || g.govt_system.agency_id, g.name, g.access_class] }
      return unless by_agency.any?

      html_map(by_agency) do |grp|
        grouping, grants = grp
        agency, name, access_class = grouping
        next if agency.nil?

        render GroupedSystemGrants.new(agency: agency, name: name, access_class: access_class, system_grants: grants)
      end
    end

    def revokes_section
      by_agency = @revokes.group_by { |g| [g.agency_id || g.govt_system.agency_id, g.name, g.access_class] }
      return unless by_agency.any?

      html_map(by_agency) do |grp|
        grouping, grants = grp
        agency, name, access_class = grouping
        next if agency.nil?

        render GroupedSystemRevokes.new(agency: agency, name: name, access_class: access_class, system_revokes: grants)
      end
    end

    def template
      html lambda {
        <<~HTML
          #{html -> { grants_section }}
          #{html -> { revokes_section }}
        HTML
      }
    end
  end
end
