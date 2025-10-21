# frozen_string_literal: true

require 'edtf'

# A class for formatting EDTF dates in standard ways
class EdtfFormat
  def initialize(date, format = :iso, filled = :none)
    @date = Date.edtf(date)
    @format = format
    @filled = filled
  end

  def fill?
    @filled == :filled
  end

  def display_exact
    case @format
    when :compact
      "#{'  ' if fill?}#{@date.strftime('%-m/%d')}"
    when :compact_year
      "#{'  ' if fill?}#{@date.strftime('%-m/%d/%y')}"
    when :iso
      "#{'  ' if fill?}#{@date.strftime('%Y-%m-%d')}"
    when :human
      @date.humanize
    end
  end

  def display_unspecified
    raise 'Need to update display_unspecified!' unless @date.unspecified?(:day) && !@date.unspecified?(:month)

    humanized = "Sometime in #{@date.strftime('%b %Y')}"
    case @format
    when :compact
      "#{'  ' if fill?}<abbr title=\"#{humanized}\">#{@date.strftime('%-m/XX')}</abbr>"
    when :compact_year
      "#{'  ' if fill?}<abbr title=\"#{humanized}\">#{@date.strftime('%-m/XX/%y')}</abbr>"
    when :iso
      "#{'  ' if fill?}<abbr title=\"#{humanized}\">#{@date.strftime('%Y-%m-XX')}</abbr>"
    when :human
      @date.humanize
    end
  end

  def display_approximate
    humanized = "On or around #{@date.strftime('%b %d, %Y')}"

    case @format
    when :compact
      "<abbr title=\"#{humanized}\">#{@date.strftime('c.%-m/%d')}</abbr>"
    when :compact_year
      "<abbr title=\"#{humanized}\">#{@date.strftime('c.%-m/%d/%y')}</abbr>"
    when :iso
      "<abbr title=\"#{humanized}\">c.#{@date}</abbr>"
    when :human
      @date.humanize
    end
  end

  def display_uncertain
    humanized = "Possibly #{@date.strftime('%b %d, %Y')}"

    case @format
    when :compact
      "<abbr title=\"#{humanized}\">#{@date.strftime('%-m/%d?')}</abbr>"
    when :compact_year
      "<abbr title=\"#{humanized}\">#{@date.strftime('%-m/%d/%y?')}</abbr>"
    when :iso
      "<abbr title=\"#{humanized}\">#{@date}?</abbr>"
    when :human
      @date.humanize
    end
  end

  def to_s
    return '' if @date.nil?

    if @date.approximate?
      display_approximate
    elsif @date.uncertain?(:day)
      display_uncertain
    elsif @date.unspecified?(:day) || @date.unspecified?(:month)
      display_unspecified
    else
      display_exact
    end
  end

  def render_in(_view_context)
    to_s
  end
end
