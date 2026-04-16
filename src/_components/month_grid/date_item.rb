# frozen_string_literal: true

module MonthGrid
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

    def extra_section
      contents = extra_contents

      if contents
        <<~HTML
          <div class="collapse-content text-sm p-0">
            <div class="ml-[25px] pt-1 flex flex-col gap-y-3">
               #{html -> { contents }}
            </div>
          </div>
        HTML
      else
        html -> { '' }
      end
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
