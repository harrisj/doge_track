# frozen_string_literal: true

module Atoms
  # A list of multiple agencies rendered in a compact style
  class ProjectsList < CompactList
    def initialize(projects, raise_miss: true, style: :list)
      super(projects, style: style)
      @raise_miss = raise_miss

      return if projects.is_a?(Array) && projects.all?(Project)

      raise ArgumentError,
            'ProjectsList argument must be an array of Project'
    end

    def render_item(project)
      <<~HTML.chomp
        <a href="#{text -> { project.path }}">#{text -> { project.label_text }}</a>
      HTML
    end
  end
end
