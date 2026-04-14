# frozen_string_literal: true

module MonthGrid
  # Represents a single converted position
  class ConversionPosition < DateRowItem
    def initialize(position)
      super
      @position = position
    end

    def id
      @position.id
    end

    def icon_id
      'converted'
    end

    def title_clause
      return unless @position.title

      text -> { " as #{text -> { @position.title }}" }
    end

    def paid?
      @position.salary && @position.salary != '$0'
    end

    def summary
      <<~HTML
        #{render Atoms::PersonLink.new(@position.person)} converted to permanent#{text -> { ' paid' if paid? }} position#{text -> { title_clause }} at #{render Atoms::AgencyLink.new(@position.agency)}
      HTML
    end

    def position_extra
      <<~HTML
        <li>#{render Atoms::PositionMoveLabel.new(position: @position)} #{render Atoms::DateRange.new(start_date: @position.start_date, end_date: @position.end_date)}</li>
      HTML
    end

    def title_extra
      return unless @position.title

      <<~HTML
        <li>#{render Atoms::Icon.new('job_title')} #{text -> { @position.title }}#{text -> { ", #{text -> { @position.office }}" if @position.office }}</li>
      HTML
    end

    def salary_extra
      return unless @position.salary

      salary = @position.salary == '$0' ? 'Volunteer' : @position.salary
      <<~HTML
        <li>#{render Atoms::Icon.new('salary')} #{text -> { salary }}#{html -> { ' (<abbr title="Special Government Employee">SGE</abbr>)' if @position.sge }}</li>
      HTML
    end

    def sources_extra
      return unless @position.sources.any?

      html_map(@position.sources) do |source|
        <<~HTML
          <li>#{render Atoms::Icon.new('source')} <a target="_blank" href="#{text -> { source.url }}">#{text -> { source.title }}</a><small> <em>#{text -> { source.publisher.name }}</em>, #{html -> { render Atoms::DateLabel.new(source.pub_date) }}</small></li>
        HTML
      end
    end

    def extra
      <<~HTML
        <ul class="list-none">
        #{html -> { position_extra }}
        #{html -> { title_extra }}
        #{html -> { salary_extra }}
        #{html -> { sources_extra }}
        #{html -> { table_note_extra }}
        </ul>
      HTML
    end

    def extra_section
      <<~HTML
        <div class="ml-[25px] pt-1">
           #{html -> { extra }}
        </div>
      HTML
    end
  end
end
