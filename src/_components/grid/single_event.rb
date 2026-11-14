# frozen_string_literal: true

module Grid
  # Represents an event in the MonthGrid
  class SingleEvent < DateItem
    include ExtraMixins

    def initialize(event:, exclude_agency_id: nil)
      super()
      @event = event
      @exclude = exclude_agency_id
    end

    def id
      @event.id
    end

    def icon_id
      @event.type
    end

    def agencies_inline
      return text -> { '' } unless @event.agencies.any?
      return text -> { '' } if @exclude && @event.agencies.map(&:id) == [@exclude]

      html lambda {
        <<~HTML.chomp
          <small>&nbsp;#{render Atoms::Icon.new('agency')}&nbsp;#{render Atoms::AgenciesList.new(@event.agencies, style: :comma, link: false)}</small>
        HTML
      }
    end

    def summary
      html lambda {
        <<~HTML.chomp
          #{html -> { @event.linkified_text }}#{html -> { agencies_inline }}
        HTML
      }
    end

    def extra_contents
      extra_table <<~HTML
        #{html -> { fuzz_extra(@event) }}
        #{html -> { people_extra(@event) }}
        #{html -> { sources_extra(@event) }}
        #{html -> { agencies_extra(@event) }}
        #{html -> { projects_extra(@event) }}
      HTML
    end
  end
end
