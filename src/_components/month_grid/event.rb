# frozen_string_literal: true

module MonthGrid
  # Represents an event in the MonthGrid
  class Event < Bridgetown::Component
    def initialize(event:)
      super()
      @event = event
    end

    def people_list
      named = []
      named += @event.people if @event.people.any?
      unnamed_aliases = @event.doge_aliases.select { |d| d.name.nil? }
      named += unnamed_aliases if unnamed_aliases.any?

      return unless named.any?

      <<~HTML.chomp
        <div class="text-base-content/75 flex flext-row">#{render CategoryLabel.new('person', :icon)}&nbsp;#{render Atoms::PeopleList.new(named)}</div>
      HTML
    end

    def projects_list
      return unless @event.projects.any?

      <<~HTML.chomp
        <div class="text-base-content/75 flex flex-row">#{render CategoryLabel.new('project', :icon)}}&nbsp;#{render Atoms::ProjectsList.new(@event.projects)}</div>
      HTML
    end
  end
end
