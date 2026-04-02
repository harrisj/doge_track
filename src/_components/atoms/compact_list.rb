# frozen_string_literal: true

module Atoms
  # A way to represent a compact list
  class CompactList < Bridgetown::Component
    def initialize(items)
      super()
      raise 'List argument must be an array' unless items.is_a?(Array)

      @items = items
    end

    def render_item(item)
      item
    end

    def template
      return unless @items.any?

      html lambda {
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
      }
    end
  end
end
