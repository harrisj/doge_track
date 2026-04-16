# frozen_string_literal: true

module MonthGrid
  # Represents a single position
  class SinglePosition < DateItem
    include ExtraMixins

    def initialize(position:)
      super()
      @position = position
    end

    def id
      @position.id
    end

    def icon_id
      @position.type
    end

    def title_clause
      return unless @position.title

      if @position.type == 'converted'
        text -> { " as #{text -> { @position.title }}" }
      else
        text -> { " to #{text -> { @position.title }}" }
      end
    end

    def paid?
      @position.salary && @position.salary != '$0'
    end

    def summary
      case @position.type
      when 'promotion'
        <<~HTML
          #{render Atoms::PersonLink.new(@position.person)} promoted #{text -> { title_clause }} at #{render Atoms::AgencyLink.new(@position.agency)}
        HTML
      when 'demotion'
        <<~HTML
          #{render Atoms::PersonLink.new(@position.person)} demoted #{text -> { title_clause }} at #{render Atoms::AgencyLink.new(@position.agency)}
        HTML
      when 'converted'
        <<~HTML
          #{render Atoms::PersonLink.new(@position.person)} converted to permanent#{text -> { ' paid' if paid? }} position#{text -> { title_clause }} at #{render Atoms::AgencyLink.new(@position.agency)}
        HTML
      end
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
