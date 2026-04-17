# frozen_string_literal: true

module MonthGrid
  # A collection of agency positions *
  class GroupedSystemRevokes < DateItem
    include ExtraMixins

    def initialize(agency:, name:, access_class:, system_revokes:)
      super()
      @agency = agency
      @name = name
      @access_class = access_class
      @system_revokes = system_revokes
    end

    def id
      ''
    end

    def icon_id
      'system_revoke'
    end

    def summary
      verb = "has #{@access_class} access revoked for"

      if @system_revokes.one?
        <<~HTML.chomp
          #{render Atoms::PersonLink.new(@name)} #{text -> { verb }} #{render Atoms::SystemLink.new(@system_revokes.first.govt_system)} at #{render Atoms::AgencyLink.new(@agency)}.
        HTML
      else
        <<~HTML.chomp
          #{render Atoms::PersonLink.new(@name)} #{text -> { verb }} #{text -> { @system_revokes.count }} systems at #{render Atoms::AgencyLink.new(@agency)}.
        HTML
      end
    end

    def system_access_extra(system_role)
      extra_item 'system_grant', <<~HTML.chomp
        #{text -> { system_role.type }}, #{render Atoms::DateRange.new(start_date: system_role.date_granted, end_date: system_role.date_revoked)} #{render Atoms::PersonLink.new(system_role.name)}
      HTML
    end

    def extra_contents
      html_map(@system_revokes) do |grant|
        extra_table <<~HTML
          #{html -> { system_name_extra(grant.govt_system) }}
          #{html -> { system_access_extra(grant) }}
          #{html -> { table_note_extra(grant.govt_system.description) }}
          #{html -> { projects_extra(grant.govt_system) }}
        HTML
      end
    end
  end
end
