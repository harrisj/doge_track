# frozen_string_literal: true

module Grid
  # A representation of the start positions
  class SystemRevokes < Bridgetown::Component
    def initialize(roles:)
      super()
      @roles = roles
    end

    def template
      text -> { '' }
    end
  end
end
