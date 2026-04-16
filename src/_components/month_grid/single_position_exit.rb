# frozen_string_literal: true

module MonthGrid
  # Represents a single position
  class SinglePositionExit < DateItem
    include ExtraMixins

    def initialize(position:)
      super()
      @position = position
    end

    def id
      @position.id
    end

    def icon_id
      'offboard'
    end

    def title_clause
      return unless @position.title

      <<~HTML.chomp
        as #{text -> { @position.title }}
      HTML
    end

    def verb
      if @position.type == 'detailed'
        'ends detailed position'
      else
        'leaves role'
      end
    end

    def govt_exit_clause
      return unless @position.person && @position.person.govt_exit_date == @position.end_date

      <<~HTML.rstrip
        <span class="font-semibold"> (exits govt. service)</class>
      HTML
    end

    def paid?
      @position.salary && @position.salary != '$0'
    end

    def summary
      <<~HTML
        #{render Atoms::PersonOrAliasLink.new(@position.person || @position.doge_alias)} #{text -> { verb }} #{html -> { title_clause }} at #{render Atoms::AgencyLink.new(@position.agency)}#{html -> { govt_exit_clause }}
      HTML
    end

    def extra_contents
      extra_table <<~HTML
        #{html -> { position_extra(@position) }}
        #{html -> { title_extra(@position) }}
        #{html -> { salary_extra(@position) }}
        #{html -> { sources_extra(@position) }}
        #{html -> { table_note_extra(@position) }}
      HTML
    end
  end
end
