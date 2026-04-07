# frozen_string_literal: true

module MonthGrid
  # A representation of the start positions
  class SystemGrants < Bridgetown::Component
    def initialize(roles:)
      super()
      @roles = roles
    end

    def template
      text -> { '' }
    end
  end
end
