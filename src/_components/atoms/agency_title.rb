# frozen_string_literal: true

module Atoms
  # A link to a person's page
  class AgencyTitle < Bridgetown::Component
    def initialize(agency:)
      super()
      @agency = agency
    end

    def title
      <<~HTML
        <h1 class="text-2xl sm:text-3xl md:text-4xl leading-none tracking-tight font-title mb-1">#{text -> { @agency.name }}</h1>
      HTML
    end

    def subtitle
      <<~HTML
        <h2 class="text-lg sm:text-xl md:text-2xl leading-none tracking-tight font-title mt-0">subagencies: #{text -> { @agency.children.map(&:short_name).sort.join(', ') }}</h2>
      HTML
    end

    def template
      html lambda {
        <<~HTML
          #{html -> { title }}
          #{html -> { subtitle if @agency.children.any? }}
        HTML
      }
    end
  end
end
