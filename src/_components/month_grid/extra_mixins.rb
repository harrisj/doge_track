# frozen_string_literal: true

module MonthGrid
  # Extra mixins
  module ExtraMixins
    def fuzz_extra(item)
      return unless item.fuzz

      <<~HTML
        <li>#{render Atoms::Icon.new('question')} <span class="italic">Fuzz: #{render Atoms::Blurb.new(item.fuzz)}</li>
      HTML
    end

    def agencies_extra(item)
      return unless item.agencies.any?

      <<~HTML
        <li>#{render Atoms::Icon.new('agency')} #{render Atoms::AgenciesList.new(item.agencies, style: :comma)}</li>
      HTML
    end

    def people_extra(item)
      return unless item.people.any?

      <<~HTML
        <li>#{render Atoms::Icon.new('person')} #{render Atoms::PeopleList.new(item.people, style: :comma)}</li>
      HTML
    end

    def projects_extra(item)
      return unless item.projects.any?

      <<~HTML
        <li>#{render Atoms::Icon.new('project')} #{render Atoms::ProjectsList.new(item.projects, style: :comma)}</li>
      HTML
    end

    def sources_extra(item)
      return unless item.sources.any?

      html_map(item.sources) do |source|
        <<~HTML
          <li>#{render Atoms::Icon.new('source')} <a target="_blank" href="#{text -> { source.url }}">#{text -> { source.title }}</a><small> <em>#{text -> { source.publisher.name }}</em>,&nbsp;#{html -> { render Atoms::DateLabel.new(source.pub_date) }}</small></li>
        HTML
      end
    end

    def table_note_extra(item)
      return unless item.table_note

      <<~HTML
        <li>#{render Atoms::Icon.new('table_note')} <span class="italic">#{text -> { item.table_note }}</span></li>
      HTML
    end

    def position_extra(position)
      <<~HTML
        <li>#{render Atoms::PositionMoveLabel.new(position: position)} #{render Atoms::PersonOrAliasLink.new(position.person || position.doge_alias)} #{render Atoms::DateRange.new(start_date: position.start_date, end_date: position.end_date)}</li>
      HTML
    end

    def title_extra(position)
      return unless position.title

      <<~HTML
        <li>#{render Atoms::Icon.new('job_title')} #{text -> { position.title }}#{text -> { ", #{text -> { position.office }}" if position.office }}</li>
      HTML
    end

    def salary_extra(position)
      return unless position.salary

      salary = position.salary == '$0' ? 'Volunteer' : position.salary
      <<~HTML
        <li>#{render Atoms::Icon.new('salary')} #{text -> { salary }}#{html -> { ' (<abbr title="Special Government Employee">SGE</abbr>)' if position.sge }}</li>
      HTML
    end
  end
end
