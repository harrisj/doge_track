# frozen_string_literal: true

module Atoms
  # A list of multiple agencies rendered in a compact style
  class AgenciesList < CompactList
    def initialize(agencies, raise_miss: true, style: :list)
      super(agencies, style: style)
      @raise_miss = raise_miss

      return if agencies.is_a?(Array) && (agencies.all?(Agency) || agencies.all?(String))

      raise ArgumentError,
            'Agencies argument must be an array of Agency objects or IDs'
    end

    def render_item(item)
      render Atoms::AgencyLink.new(item, raise_miss: @raise_miss)
    end
  end
end
