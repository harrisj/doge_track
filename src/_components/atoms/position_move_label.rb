# frozen_string_literal: true

module Atoms
  # Renders a move label for a position
  class PositionMoveLabel < Bridgetown::Component
    ALLOWED_CONTEXTS = [:agency].freeze
    def initialize(position:, context: :agency)
      super()
      @position = position
      @context = context
    end
  end
end
