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
          content <<~HERE
            {%@ Atoms::Title title: "#{current.strftime('%b %Y')}" %}
            <div class="my-2">
            {%@ Grid::Month year: #{current.year}, month: #{current.month} %}
            </div>
          HERE
        end

        current >>= 1
      end
    end
  end
end
