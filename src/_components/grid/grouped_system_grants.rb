# frozen_string_literal: true

module Grid
  # A collection of agency positions *
  class GroupedSystemGrants < DateItem
    include ExtraMixins

    def initialize(agency:, people:, access_class:, system_grants:)
      super()
      @agency = agency
      @people = people
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
      verb_start = @people.one? ? 'is' : 'are'
      verb = "#{verb_start} granted #{@access_class} access to"

      systems = @system_grants.map(&:govt_system).uniq

      if systems.one?
        <<~HTML.chomp
          #{render Atoms::PeopleList.new(@people, style: :sentence)} #{text -> { verb }} #{render Atoms::SystemLink.new(systems.first)} at #{render Atoms::AgencyLink.new(@agency)}.
        HTML
      else
        <<~HTML.chomp
          #{render Atoms::PeopleList.new(@people, style: :sentence)} #{text -> { verb }} <strong>#{text -> { systems.count }} systems</strong> at #{render Atoms::AgencyLink.new(@agency)}.
        HTML
      end
    end

    def system_access_extra(system_role)
      extra_item 'system_grant', <<~HTML.chomp
        #{text -> { system_role.type }}, #{render Atoms::DateRange.new(start_date: system_role.date_granted, end_date: system_role.date_revoked)} #{render Atoms::PersonLink.new(system_role.name)}
      HTML
    end

    def extra_contents
      grouped = @system_grants.group_by(&:govt_system)

      html_map(grouped) do |grp|
        govt_system, grants = grp

        extra_table <<~HTML
          #{html -> { system_name_extra(govt_system) }}
          #{html_map(grants) do |grant|
            <<~HTML
              #{html -> { system_access_extra(grant) }}
            HTML
          end }
          #{html -> { table_note_extra(govt_system.description) }}
          #{html -> { projects_extra(govt_system) }}
        HTML
      end
    end
  end
end
