# frozen_string_literal: true

module Atoms
  # A date range component
  class DateRange < Bridgetown::Component
    def initialize(start_date: nil, end_date: nil, always_dash: false, date_format: :compact, padding: :none)
      super()
      @start_date = start_date
      @end_date = end_date
      @always_dash = always_dash
      @format = date_format
      @padding = padding
    end

    def template
      return unless @start_date || @end_date

      render html lambda {
        <<~HTML
          <span class="md:text-nowrap my-date">
        HTML
      }

      render ::EdtfFormat.new(@start_date, @date_format, @padding)

      render text -> { '-' } if @always_dash || @end_date

      render ::EdtfFormat.new(@end_date, @date_format, @padding) if @end_date

      render html -> { '</span>' }
    end
  end
end
