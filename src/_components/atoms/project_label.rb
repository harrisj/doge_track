# frozen_string_literal: true

module Atoms
  # Project label
  class ProjectLabel < Bridgetown::Component
    def initialize(project:)
      super()
      @project = project
    end

    def template
      html lambda {
        <<~HTML.chomp
          <div aria-label="Project: #{text -> { @project.label_text }}" class="status status-md status-#{text -> { @project.label_color }}"></div>
        HTML
      }
    end
  end
end
