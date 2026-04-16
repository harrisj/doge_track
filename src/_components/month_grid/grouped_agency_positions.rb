# frozen_string_literal: true

module MonthGrid
  # A collection of agency positions *
  class GroupedAgencyPositions < DateItem
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

    def hires_summary
      return unless @hires.any?

      people = @hires.map { |pos| pos.person || pos.doge_alias }
      verb = people.one? ? 'starts' : 'start'

      all_titles = @hires.map(&:title).uniq
      title = all_titles.one? ? " as #{all_titles[0]}" : ''

      <<~HTML.chomp
        #{text -> { ' ' }}#{render Atoms::PeopleList.new(people, style: :sentence)} #{text -> { verb }}#{text -> { title }} at #{render Atoms::AgencyLink.new(@agency)}.
      HTML
    end

    def details_summary
      return unless @details.any?

      grouped_from = @details.group_by(&:from_agency_id)

      html_map(grouped_from) do |grp|
        from_id, positions = grp
        people = positions.map { |pos| pos.person || pos.doge_alias }

        if from_id
          <<~HTML.chomp
            #{text -> { ' ' }}#{render Atoms::PeopleList.new(people, style: :sentence)} detailed from #{render Atoms::AgencyLink.new(from_id)} to #{render Atoms::AgencyLink.new(@agency)}
          HTML
        else
          <<~HTML.chomp
            #{text -> { ' ' }}#{render Atoms::PeopleList.new(people, style: :sentence)} detailed from unknown agency to #{render Atoms::AgencyLink.new(@agency)}.
          HTML
        end
      end
    end

    def summary
      raise "This shouldn't happen" if @details.empty? && @hires.empty?

      <<~HTML.chomp
        #{html -> { hires_summary }} #{html -> { details_summary }}
      HTML
    end

    def extra_contents
      html_map(@positions) do |position|
        <<~HTML
           <div>
             <ul class="list-none">
               #{html -> { position_extra(position) }}
               #{html -> { title_extra(position) }}
               #{html -> { salary_extra(position) }}
               #{html -> { sources_extra(position) }}
               #{html -> { table_note_extra(position) }}
             </ul>
          </div>
        HTML
      end
    end
  end
end
