# frozen_string_literal: true

require 'edtf'

module Atoms
  # A date range component
  class DateLabel < Bridgetown::Component
    def initialize(date, date_format: :compact_year, padding: :none)
      super()
      @date = if date.is_a? String
                ::Date.edtf(date)
              else
                date
              end

      raise ArgumentError, "Format #{date_format} unknown" unless %i[compact compact_year
                                                                     iso human].include?(date_format)

      @format = date_format
      @padding = padding
    end

    def pad?
      @padding == :filled
    end

    def display_exact
      case @format
      when :compact
        <<~HTML.chomp
          #{text -> { '  ' if pad? }}#{text -> { @date.strftime('%-m/%d') }}
        HTML
      when :compact_year
        <<~HTML.chomp
          #{text -> { '  ' if pad? }}#{text -> { @date.strftime('%-m/%d/%y') }}
        HTML
      when :iso
        <<~HTML.chomp
          #{text -> { '  ' if pad? }}#{text -> { @date.strftime('%Y-%m-%d') }}
        HTML
      when :human
        text -> { @date.humanize }
      end
    end

    def display_unspecified
      raise 'Need to update display_unspecified!' unless @date.unspecified?(:day) && !@date.unspecified?(:month)

      humanized = "Sometime in #{@date.strftime('%b %Y')}"
      case @format
      when :compact
        <<~HTML.chomp
          #{text -> { '  ' if pad? }}<abbr title="#{text -> { humanized }}">#{text -> { @date.strftime('%-m/XX') }}</abbr>
        HTML
      when :compact_year
        <<~HTML.chomp
          #{text -> { '  ' if pad? }}<abbr title="#{text -> { humanized }}">#{text -> { @date.strftime('%-m/XX/%y') }}</abbr>
        HTML
      when :iso
        <<~HTML.chomp
          #{text -> { '  ' if pad? }}<abbr title="#{text -> { humanized }}">#{text -> { @date.strftime('%Y-%m-XX') }}</abbr>
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
          <abbr title="#{text -> { humanized }}">#{text -> { @date.strftime('c.%-%Y-%m-%d') }}</abbr>
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

    # def to_s
    #   return '' if @date.nil?

    #   if @date.approximate?
    #     display_approximate
    #   elsif @date.uncertain?(:day)
    #     display_uncertain
    #   elsif @date.unspecified?(:day) || @date.unspecified?(:month)
    #     display_unspecified
    #   else
    #     display_exact
    #   end
    # end

    def template
      html lambda {
        if @date.nil?
          ''
        elsif @date.approximate?
          display_approximate
        elsif @date.uncertain?(:day)
          display_uncertain
        elsif @date.unspecified?(:day) || @date.unspecified?(:month)
          display_unspecified
        else
          display_exact
        end.strip
      }
    end
  end
end
