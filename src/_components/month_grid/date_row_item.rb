# frozen_string_literal: true

module MonthGrid
  # An individual item
  class DateRowItem < Bridgetown::Component
    def initialize(item = nil)
      super()
      @item = item
    end

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

    def sources_extra
      return unless @item.sources.any?

      html_map(@item.sources) do |source|
        <<~HTML
          <li>#{render Atoms::Icon.new('source')} <a target="_blank" href="#{text -> { source.url }}">#{text -> { source.title }}</a><small> <em>#{text -> { source.publisher.name }}</em>,&nbsp;#{html -> { render Atoms::DateLabel.new(source.pub_date) }}</small></li>
        HTML
      end
    end

    def table_note_extra
      return unless @item.table_note

      <<~HTML
        <li>#{render Atoms::Icon.new('table_note')} <span class="italic">#{text -> { @item.table_note }}</li>
      HTML
    end

    def extra
      <<~HTML
        <ul class="list-none">
        #{html -> { sources_extra }}
        #{html -> { table_note_extra }}
        </ul>
      HTML
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
      <<~HTML
        <div class="ml-[25px] pt-1">
           #{html -> { extra }}
        </div>
      HTML
    end

    def template
      html lambda {
        <<~HTML
          <details class="collapse">
            <summary class="collapse-title p-0">#{html -> { summary_section }}</summary>
              <div class="collapse-content text-sm p-0">
                #{html -> { extra_section }}
              </div>
          </details>
        HTML
      }
    end
  end
end
