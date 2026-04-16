# frozen_string_literal: true

module MonthGrid
  # A representation of the start positions
  class SingleExecOrder < DateItem
    include ExtraMixins

    def initialize(order:)
      super()
      @order = order
    end

    def id
      @order.id
    end

    def icon_id
      'exec_order'
    end

    def summary
      <<~HTML.chomp
        <a class="link-hover" href="#{text -> { @order.page_url }}">EO #{text -> { @order.id }}</a>: #{text -> { @order.title }}
      HTML
    end

    def exec_order_extra(order)
      <<~HTML
        <li>#{render Atoms::Icon.new('table_note')} <em>#{text -> { order.short_summary }}</em></li>
      HTML
    end

    def extra_contents
      <<~HTML
        <ul class="list-none">
        #{html -> { exec_order_extra(@order) }}
        #{html -> { agencies_extra(@order) }}
        </ul>
      HTML
    end
  end
end
