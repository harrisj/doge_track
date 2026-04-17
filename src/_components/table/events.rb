# frozen_string_literal: true

module Table
  # A compact table of events
  class Events < Bridgetown::Component
    def initialize(events, month_separator: true, show_directories: true, show_projects: false, agency: nil)
      super()
      @events = events
      @month_separator = month_separator
      @show_directories = show_directories
      @show_projects = show_projects
      @agency = agency

      return unless @events.any?

      @events.sort_by! { |e| e.date.to_s }
    end
  end
end
