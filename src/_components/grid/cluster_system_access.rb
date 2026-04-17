# frozen_string_literal: true

module Grid
  # A representation of the start positions
  class ClusterSystemAccess < Bridgetown::Component
    def initialize(grants:, revokes:)
      super()
      @grants = grants
      @revokes = revokes
    end

    def basic_grants_section
      basic = @grants.select { |g| g.access_class == 'basic' }
      basic_group = basic.group_by { |g| g.agency_id || g.govt_system.agency_id }

      html_map(basic_group) do |grp|
        agency, grants = grp
        next if agency.nil?

        people = grants.map(&:person).uniq.sort_by(&:sort_name)
        render GroupedSystemGrants.new(agency: agency, people: people, access_class: 'basic', system_grants: grants)
      end
    end

    def elevated_grants_section
      elevated = @grants.select { |g| g.access_class == 'elevated' }
      elevated_group = elevated.group_by { |g| [g.agency_id || g.govt_system.agency_id, g.name] }

      html_map(elevated_group) do |grp|
        grouping, grants = grp
        agency, name = grouping
        next if agency.nil?

        grants.map(&:person).uniq.sort_by(&:sort_name)

        render GroupedSystemGrants.new(agency: agency, people: [name], access_class: 'elevated', system_grants: grants)
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
          #{html -> { basic_grants_section }}
          #{html -> { elevated_grants_section }}
          #{html -> { revokes_section }}
        HTML
      }
    end
  end
end
