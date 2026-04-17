#!/usr/bin/env ruby
# frozen_string_literal: true

module Atoms
  # Renders a page title
  class Title < Bridgetown::Component
    def initialize(title:)
      super()
      @title = title
    end

    def template
      html lambda {
        <<~HTML
          <h1 class="font-title text-2xl sm:text-3xl md:text-4xl mb-4">#{text -> { @title }}</h1>
        HTML
      }
    end
  end
end
