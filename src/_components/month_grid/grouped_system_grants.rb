# frozen_string_literal: true

module MonthGrid
  # A collection of agency positions *
  class GroupedSystemGrants < DateItem
    include ExtraMixins

    def initialize(agency:, govt_system:, system_grants:)
      super()
      @agency = agency
      @govt_system = govt_system
      @system_grants = system_grants
    end

    def id
      ''
    end

    def icon_id
      'system_grant'
    end

    def summary
      people = @system_grants.map { |g| g.person || g.doge_alias }
      admin = @system_grants.any? { |g| %w[admin read_write].include?(g.type) }

      access = admin ? 'elevated access' : 'access'
      verb = people.one? ? "is granted #{access} to" : "are granted #{access} to"

      <<~HTML.chomp
        #{render Atoms::PeopleList.new(people, style: :sentence)} #{text -> { verb }} #{render Atoms::SystemLink.new(@govt_system)} at #{render Atoms::AgencyLink.new(@agency)}.
      HTML
    end

    def extra_contents
      by_type = @system_grants.group_by { |g| [g.type, g.date_revoked] }

      extra_table <<~HTML
        #{html -> { system_name_extra(@govt_system) }}

        #{html_map(by_type) do |grp|
          _, grants = grp
          grants.map(&:person)

          access_type_extra(grants)
        end }

        #{html -> { table_note_extra(@govt_system.description) }}
        #{html -> { projects_extra(@govt_system) }}
      HTML
    end
  end
end
