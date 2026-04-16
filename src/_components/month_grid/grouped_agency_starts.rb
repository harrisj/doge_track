# frozen_string_literal: true

module MonthGrid
  # A collection of agency positions *
  class GroupedAgencyStarts < DateItem
    include ExtraMixins

    def initialize(agency_id:, positions:)
      super()
      @agency = Agency.with_pk!(agency_id)
      @positions = positions

      @details, @hires = @positions.partition { |pos| pos.type == 'detailed' }
    end

    def id
      ''
    end

    def icon_id
      'appointed'
    end

    def summary
      people = @positions.map { |pos| pos.person || pos.doge_alias }
      verb = people.one? ? 'starts' : 'start'

      all_titles = @hires.map(&:title).uniq
      title = all_titles.one? ? " as #{all_titles[0]}" : ''

      <<~HTML.chomp
        #{text -> { ' ' }}#{render Atoms::PeopleList.new(people, style: :sentence)} #{text -> { verb }}#{text -> { title }} at #{render Atoms::AgencyLink.new(@agency)}.
      HTML
    end

    def extra_contents
      html_map(@positions) do |position|
        extra_table <<~HTML
          #{html -> { position_extra(position) }}
          #{html -> { title_extra(position) }}
          #{html -> { salary_extra(position) }}
          #{html -> { sources_extra(position) }}
          #{html -> { table_note_extra(position) }}
        HTML
      end
    end
  end
end
