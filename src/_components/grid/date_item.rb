# frozen_string_literal: true

module Grid
  # An individual item
  class DateItem < Bridgetown::Component
    def id
      ''
    end

    def icon_id
      ''
    end

    def icon
      render Atoms::Icon.new(icon_id)
    end

    def summary
      ''
    end

    def summary_section
      <<~HTML
        <div class="grid grid-cols-[18px_auto] gap-x-1 p-0 min-h-0">
          <div>#{html -> { icon }}</div>
          <div class="font-sans" id="#{text -> { id }}">
              #{html -> { summary }}
          </div>
        </div>
      HTML
    end

    def template
      html lambda {
        <<~HTML
          <details class="collapse">
            <summary class="collapse-title p-0">#{html -> { summary_section }}</summary>
            #{html -> { extra_section }}
          </details>
        HTML
      }
    end
  end
end
