# frozen_string_literal: true

module Grid
  # A collection of agency positions *
  class GroupedAgencyDetails < DateItem
    include ExtraMixins

    def initialize(agency_id:, from_agency_id:, positions:)
      super()
      @agency = Agency.with_pk!(agency_id)
      @from_agency = from_agency_id ? Agency.with_pk!(from_agency_id) : nil
      @positions = positions
    end

    def id
      ''
    end

    def icon_id
      'detailed'
    end

    def summary
      people = @positions.map { |pos| pos.person || pos.doge_alias }

      if @from_agency
        <<~HTML.chomp
          #{text -> { ' ' }}#{render Atoms::PeopleList.new(people, style: :sentence)} detailed from #{render Atoms::AgencyLink.new(@from_agency)} to #{render Atoms::AgencyLink.new(@agency)}
        HTML
      else
        <<~HTML.chomp
          #{text -> { ' ' }}#{render Atoms::PeopleList.new(people, style: :sentence)} detailed from unknown agency to #{render Atoms::AgencyLink.new(@agency)}.
        HTML
      end
    end

    def extra_contents
      html_map(@positions) do |position|
        extra_table <<~HTML
          #{html -> { position_extra(position) }}
          #{html -> { title_extra(position) }}
          #{html -> { salary_extra(position) }}
          #{html -> { sources_extra(position) }}
          #{html -> { table_note_extra(position.table_note) }}
        HTML
      end
    end
  end
end
