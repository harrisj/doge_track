# frozen_string_literal: true

module Atoms
  # A date range component
  class DateRange < Bridgetown::Component
    def initialize(start_date: nil, end_date: nil, always_dash: false, date_format: :compact_year, padding: :none)
      super()
      @start_date = start_date
      @end_date = end_date
      @always_dash = always_dash
      @date_format = date_format
      @padding = padding
    end

    def endash
      return '' unless @always_dash || @end_date

      '-'
    end

    def template
      return unless @start_date || @end_date

      html lambda {
        <<~HTML
          <span class="md:text-nowrap my-date">#{render Atoms::DateLabel.new(@start_date, date_format: @date_format, padding: @padding)}#{text -> { endash }}#{render Atoms::DateLabel.new(@end_date, date_format: @date_format, padding: @padding)}</span>
        HTML
      }
    end
  end
end
