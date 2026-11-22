# frozen_string_literal: true

ENV['MT_NO_EXPECTATIONS'] = 'true'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/sequel'
Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new]

require 'bridgetown/test'

module ComponentTestHelpers
  # Render a component to a plain String, unwrapping the callable that
  # Bridgetown's html templates return.
  def render_component(component)
    rendered = Bridgetown::TemplateView.render(component)

    rendered.respond_to?(:call) ? rendered.call : rendered
  end
end

module Minitest
  class Test
    include ComponentTestHelpers
  end
end
