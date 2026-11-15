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

    def id_attr
      return unless id

      <<~HTML.rstrip
        id="#{text -> { id }}"
      HTML
    end

    def summary_section
      <<~HTML
        <div class="grid grid-cols-[18px_auto] gap-x-1 items-start">
          <div>#{html -> { icon }}</div>
          <div class="flex items-start gap-x-1">
            <div class="font-sans" #{html -> { id_attr }}>#{html -> { summary }}</div>
            <div class="collapse-indicator">
              <i class="fa-sharp fa-regular fa-chevron-right fa-50 open:rotate-90" aria-hidden="true"></i>
            </div>
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
