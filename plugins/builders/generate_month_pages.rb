# frozen_string_literal: true

module Builders
  # Save out a static API
  class GenerateMonthPages < SiteBuilder
    def build
      current = Date.parse('2025-01-20')
      today = Event.max_date
      end_date = (Date.new(today.year, today.month, 1) >> 1) - 1

      while current <= end_date
        add_resource :months, "#{current.strftime('%Y-%m')}.serb" do
          layout :page
          title current.strftime('%b %Y')
          permalink "/timeline/#{current.strftime('%Y/%m')}/"
          index_for_search true
          content <<~TEXT
            {%@ Atoms::Title title: "#{current.strftime('%b %Y')}" %}

            {%@ 'month_page', year: #{current.year}, month: #{current.month} %}
          TEXT
        end

        current >>= 1
      end
    end
  end
end
