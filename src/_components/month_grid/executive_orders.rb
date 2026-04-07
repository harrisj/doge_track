# frozen_string_literal: true

module MonthGrid
  # A representation of the start positions
  class ExecutiveOrders < Bridgetown::Component
    def initialize(orders:)
      super()
      @orders = orders
    end

    def template
      html lambda {
        html_map(@orders) do |order|
          <<~HTML
            <div class="text-center"><i class="fa-sharp fa-solid fa-file-contract"></i></div>
            <div><a class="link-hover" href="#{text -> { order.page_url }}">EO #{text -> { order.id }}: #{text -> { order.title }}</a>: <em>#{text -> { order.short_summary }}</em></div>
          HTML
        end
      }
    end
  end
end
