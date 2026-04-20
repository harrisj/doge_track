# frozen_string_literal: true

module Grid
  # A data legend element. Eventual goal is to make this a little expandable widget
  class Legend < Bridgetown::Component
    def initialize(type = :focused)
      super()
      @type = type
    end

    def template
      html -> { ' ' }

      # html lambda {
      #   <<~HTML
      #     <div class="text-xs italic">#{render Atoms::Icon.new('info')} Click items to expand</div>
      #   HTML
      # }
    end
  end
end
