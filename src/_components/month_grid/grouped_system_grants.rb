# frozen_string_literal: true

module MonthGrid
  # A collection of agency positions *
  class GroupedSystemGrants < DateItem
    include ExtraMixins

    def initialize(agency:, name:, access_class:, system_grants:)
      super()
      @agency = agency
      @name = name
      @access_class = access_class
      @system_grants = system_grants
    end

    def id
      ''
    end

    def icon_id
      'system_grant'
    end

    def summary
      verb = "is granted #{@access_class} access to"

      if @system_grants.one?
        <<~HTML.chomp
          #{render Atoms::PersonLink.new(@name)} #{text -> { verb }} #{render Atoms::SystemLink.new(@system_grants.first.govt_system)} at #{render Atoms::AgencyLink.new(@agency)}.
        HTML
      else
        <<~HTML.chomp
          #{render Atoms::PersonLink.new(@name)} #{text -> { verb }} #{text -> { @system_grants.count }} systems at #{render Atoms::AgencyLink.new(@agency)}.
        HTML
      end
    end

    def system_access_extra(system_role)
      extra_item 'system_grant', <<~HTML.chomp
        #{text -> { system_role.type }}, #{render Atoms::DateRange.new(start_date: system_role.date_granted, end_date: system_role.date_revoked)} #{render Atoms::PersonLink.new(system_role.name)}
      HTML
    end

    def extra_contents
      html_map(@system_grants) do |grant|
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
