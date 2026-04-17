# frozen_string_literal: true

module MonthGrid
  # Represents an event in the MonthGrid
  class SingleEvent < DateItem
    include ExtraMixins

    def initialize(event:)
      super()
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

    def extra_contents
      extra_table <<~HTML
        #{html -> { fuzz_extra(@event) }}
        #{html -> { sources_extra(@event) }}
        #{html -> { agencies_extra(@event) }}
        #{html -> { people_extra(@event) }}
        #{html -> { projects_extra(@event) }}
      HTML
    end
  end
end
