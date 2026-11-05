# frozen_string_literal: true

require 'edtf'

module Atoms
  # A date label component
  class DateLabel < Bridgetown::Component
    def initialize(date, interval_display: :start, date_format: :compact_year, padding: :none)
      super()
      @date = if date.is_a? String
                ::EDTF.parse(date)
              else
                date
              end

      raise ArgumentError, "Interval display #{interval_display} must be :start, :end or :full" unless
        %i[start end full].include?(interval_display)
      raise ArgumentError, "Format #{date_format} unknown" unless %i[compact compact_year
                                                                     iso human].include?(date_format)

      @interval_display = interval_display
      @format = date_format
      @padding = padding
    end

    def display_exact
      if @date.is_a?(EDTF::Interval)
        min_date = @date.min if @interval_display != :end
        max_date = @date.max if @interval_display != :start
        if min_date && max_date
          display_interval(min_date, max_date)
        else
          # Interval has open/unspecified bounds; use available bound for single-date display
          single_date = min_date || max_date
          if single_date && min_date
            display_abbr(single_date, interval_description(min_date), '≥')
          elsif single_date && max_date
            display_abbr(single_date, interval_description(nil, max_date), '≤')
          else
            # Both nil: nothing to display
            ''
          end
        end
      else
        display_single_date(@date)
      end
    end

    def display_unspecified
      raise 'Need to update display_unspecified!' unless @date.unspecified?(:day) && !@date.unspecified?(:month)

      humanized = "Sometime in #{@date.strftime('%b %Y')}"
      case @format
      when :compact
        <<~HTML.chomp
          <abbr title="#{text -> { humanized }}">#{text -> { @date.strftime('%-m/XX') }}</abbr>
        HTML
      when :compact_year
        <<~HTML.chomp
          <abbr title="#{text -> { humanized }}">#{text -> { @date.strftime('%-m/XX/%y') }}</abbr>
        HTML
      when :iso
        <<~HTML.chomp
          <abbr title="#{text -> { humanized }}">#{text -> { @date.strftime('%Y-%m-XX') }}</abbr>
        HTML
      when :human
        text -> { @date.humanize }
      end
    end

    def display_approximate
      humanized = "On or around #{@date.strftime('%b %d, %Y')}"

      case @format
      when :compact
        <<~HTML.chomp
          <abbr title="#{text -> { humanized }}">#{text -> { @date.strftime('c.%-m/%d') }}</abbr>
        HTML
      when :compact_year
        <<~HTML.chomp
          <abbr title="#{text -> { humanized }}">#{text -> { @date.strftime('c.%-m/%d/%y') }}</abbr>
        HTML
      when :iso
        <<~HTML.chomp
          <abbr title="#{text -> { humanized }}">#{text -> { @date.strftime('c.%Y-%m-%d') }}</abbr>
        HTML
      when :human
        text -> { @date.humanize }
      end
    end

    def display_uncertain
      humanized = "Possibly #{@date.strftime('%b %d, %Y')}"

      case @format
      when :compact
        <<~HTML.chomp
          <abbr title="#{text -> { humanized }}">#{text -> { @date.strftime('%-m/%d?') }}</abbr>
        HTML
      when :compact_year
        <<~HTML.chomp
          <abbr title="#{text -> { humanized }}">#{text -> { @date.strftime('%-m/%d/%y?') }}</abbr>
        HTML
      when :iso
        <<~HTML.chomp
          <abbr title="#{text -> { humanized }}">#{text -> { @date }}?</abbr>
        HTML
      when :human
        text -> { @date.humanize }
      end
    end

    def display_interval(min_date, max_date)
      description = interval_description(min_date, max_date)
      case @format
      when :compact
        <<~HTML.chomp
          <abbr title="#{text -> { description }}">#{text -> { min_date.strftime('%-m/%d') }}–#{text -> { max_date.strftime('%-m/%d') }}</abbr>
        HTML
      when :compact_year
        <<~HTML.chomp
          <abbr title="#{text -> { description }}">#{text -> { min_date.strftime('%-m/%d/%y') }}–#{text -> { max_date.strftime('%-m/%d/%y') }}</abbr>
        HTML
      when :iso
        <<~HTML.chomp
          <abbr title="#{text -> { description }}">#{text -> { min_date.strftime('%Y-%m-%d') }}–#{text -> { max_date.strftime('%Y-%m-%d') }}</abbr>
        HTML
      when :human
        interval_text = "from #{min_date.strftime('%b %d, %Y')} to #{max_date.strftime('%b %d, %Y')}"
        "<abbr title=\"#{description}\">#{interval_text}</abbr>"
      end
    end

    def display_abbr(single_date, description, prefix)
      "<abbr title=\"#{description}\">#{prefix}#{display_single_date(single_date)}</abbr>"
    end

    def interval_description(min_date, max_date = nil)
      if min_date && max_date
        "Unknown day between #{min_date.strftime('%b %d, %Y')} and #{max_date.strftime('%b %d, %Y')}"
      elsif min_date
        "On or after #{min_date.strftime('%b %d, %Y')}"
      else
        "On or before #{max_date.strftime('%b %d, %Y')}"
      end
    end

    def display_single_date(single_date)
      case @format
      when :compact
        <<~HTML.chomp
          #{text -> { single_date.strftime('%-m/%d') }}
        HTML
      when :compact_year
        <<~HTML.chomp
          #{text -> { single_date.strftime('%-m/%d/%y') }}
        HTML
      when :iso
        <<~HTML.chomp
          #{text -> { single_date.strftime('%Y-%m-%d') }}
        HTML
      when :human
        text -> { single_date.humanize }
      end
    end

    def template
      html lambda {
        if @date.nil?
          ''
        elsif @date.is_a?(EDTF::Interval)
          display_exact
        elsif @date.respond_to?(:approximate?) && @date.approximate?
          display_approximate
        elsif @date.uncertain?(:day)
          display_uncertain
        elsif @date.unspecified?(:day) || @date.unspecified?(:month)
          display_unspecified
        # rubocop:disable Lint/DuplicateBranch
        else
          display_exact
        end.strip
        # rubocop:enable Lint/DuplicateBranch
      }
    end
  end
end
