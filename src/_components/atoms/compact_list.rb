# frozen_string_literal: true

module Atoms
  # A way to represent a compact list
  class CompactList < Bridgetown::Component
    def initialize(items, style: :list)
      super()
      raise ArgumentError, 'List argument must be an array' unless items.is_a?(Array)
      raise ArgumentError, 'Style must be :list, :comma or :sentence' unless %i[list sentence comma].include?(style)

      @items = items
      @style = style
    end

    def render_item(item)
      item
    end

    def template
      return unless @items.any?

      html lambda {
        case @style
        when :list
          <<~HTML
            <ul class="inline-compact">
              #{ html_map(@items) do |item|
                <<~HTML.chomp
                  <li class="inline-compact">#{html -> { render_item(item) }}</li>
                HTML
              end
              }
            </ul>
          HTML
        when :comma
          if @items.one?
            render_item(@items[0])
          else
            <<~HTML.chomp
              #{ html_map(@items[0..-2]) do |item|
                <<~HTML.chomp
                  #{html -> { render_item(item) }}#{text -> { ', ' }}
                HTML
              end
              } #{html -> { render_item(@items[-1]) }}
            HTML
          end
        when :sentence
          if @items.one?
            render_item(@items[0])
          elsif @items.count == 2
            <<~HTML.chomp
              #{html -> { render_item(@items[0]) }} and #{html -> { render_item(@items[1]) }}
            HTML
          else
            <<~HTML.chomp
              #{ html_map(@items[0..-2]) do |item|
                <<~HTML.chomp
                  #{html -> { render_item(item) }}#{text -> { ', ' }}
                HTML
              end
              }and #{html -> { render_item(@items[-1]) }}
            HTML
          end
        else
          raise ArgumentError, 'Wrong style argument'
        end
      }
    end
  end
end
