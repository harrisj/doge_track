# frozen_string_literal: true

module MonthGrid
  # A collection of agency positions *
  class GroupedSystemRevokes < DateItem
    include ExtraMixins

    def initialize(agency:, govt_system:, system_revokes:)
      super()
      @agency = agency
      @govt_system = govt_system
      @system_revokes = system_revokes
    end

    def id
      ''
    end

    def icon_id
      'system_revoke'
    end

    def summary
      people = @system_revokes.map { |g| g.person || g.doge_alias }.uniq
      admin = @system_revokes.any? { |g| %w[admin read_write].include?(g.type) }

      access = admin ? 'elevated access' : 'access'
      verb = "has #{access} revoked for"

      <<~HTML.chomp
        #{render Atoms::PeopleList.new(people, style: :sentence)} #{text -> { verb }} #{render Atoms::SystemLink.new(@govt_system)} at #{render Atoms::AgencyLink.new(@agency)}.
      HTML
    end

    def extra_contents
      by_type = @system_revokes.group_by { |g| [g.type, g.date_granted] }

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
