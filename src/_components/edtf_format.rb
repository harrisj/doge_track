# frozen_string_literal: true

require 'edtf'

# A class for formatting EDTF dates in standard ways
class EdtfFormat
  def initialize(date, format = :iso, filled = :none)
    @date = Date.edtf(date)
    @format = format
    @filled = filled
  end

  def display_exact
    case @format
    when :compact
      "#{'  ' if @filled}#{@date.strftime('%m/%d')}"
    when :iso
      "#{'  ' if @filled}#{@date.strftime('%Y-%m-%d')}"
    when :human
      @date.humanize
    end
  end

  def display_unspecified
    raise 'Need to update display_unspecified!' unless @date.unspecified?(:day) && !@date.unspecified?(:month)

    humanized = "Sometime in #{@date.strftime('%b %Y')}"
    case @format
    when :compact
      "#{'  ' if @filled}<abbr title=\"#{humanized}\">#{@date.strftime('%m-XX')}</abbr>"
    when :iso
      "#{'  ' if @filled}<abbr title=\"#{humanized}\">#{@date.strftime('%Y-%m-XX')}</abbr>"
    when :human
      @date.humanize
    end
  end

  def display_approximate
    humanized = "On or around #{@date.strftime('%b %d, %Y')}"

    case @format
    when :compact
      "<abbr title=\"#{humanized}\">#{@date.strftime('c.%m/%d')}</abbr>"
    when :iso
      "<abbr title=\"#{humanized}\">c.#{@date}</abbr>"
    when :human
      @date.humanize
    end
  end

  def render_in(_view_context)
    return '' if @date.nil?

    if @date.approximate?
      display_approximate
    elsif @date.unspecified?(:day) || @date.unspecified?(:month)
      display_unspecified
    else
      display_exact
    end
  end
end
