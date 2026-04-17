# frozen_string_literal: true

module Grid
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
      extra_item 'table_note', <<~HTML
        <em>#{text -> { order.short_summary }}</em>
      HTML
    end

    def extra_contents
      extra_table <<~HTML
        #{html -> { exec_order_extra(@order) }}
        #{html -> { agencies_extra(@order) }}
      HTML
    end
  end
end
