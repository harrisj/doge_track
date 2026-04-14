# frozen_string_literal: true

module MonthGrid
  # Represents an event in the MonthGrid
  class Event < DateRowItem
    def initialize(event:)
      super(event)
      @event = event
    end

    def id
      @event.id
    end

    def icon_id
      @event.type
    end

    def summary
      <<~HTML.chomp
        #{html -> { @event.linkified_text }}
      HTML
    end

    def fuzz_extra
      return unless @event.fuzz

      <<~HTML
        <li>#{render Atoms::Icon.new('question')} <span class="italic">Fuzz: #{render Atoms::Blurb.new(@event.fuzz)}</li>
      HTML
    end

    def agencies_extra
      return unless @event.agencies.any?

      <<~HTML
        <li>#{render Atoms::Icon.new('agency')} #{render Atoms::AgenciesList.new(@event.agencies, style: :sentence)}</li>
      HTML
    end

    def people_extra
      return unless @event.people.any?

      <<~HTML
        <li>#{render Atoms::Icon.new('person')} #{render Atoms::PeopleList.new(@event.people, style: :sentence)}</li>
      HTML
    end

    def projects_extra
      return unless @event.projects.any?

      <<~HTML
        <li>#{render Atoms::Icon.new('project')} #{render Atoms::ProjectsList.new(@event.projects, style: :sentence)}</li>
      HTML
    end

    def extra
      <<~HTML
        <ul class="list-none">
        #{html -> { fuzz_extra }}
        #{html -> { sources_extra }}
        #{html -> { agencies_extra }}
        #{html -> { people_extra }}
        #{html -> { projects_extra }}
        </ul>
      HTML
    end
  end
end
