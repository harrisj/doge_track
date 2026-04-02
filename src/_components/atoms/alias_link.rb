# frozen_string_literal: true

module Atoms
  # A link to an agency's page
  class AliasLink < Bridgetown::Component
    def initialize(doge_alias = nil, display: nil, raise_miss: true)
      super()

      raise ArgumentError, 'AliasLink: you must provide a DogeAlias object or an ID' if doge_alias.nil? && raise_miss

      if doge_alias.is_a?(DogeAlias)
        @doge_alias = doge_alias
      elsif doge_alias.is_a? String
        @doge_alias = DogeAlias[doge_alias]

        raise Sequel::NoMatchingRow, "Unable to find doge alias with ID #{doge_alias}" if @doge_alias.nil? && raise_miss
      else
        @doge_alias = nil
      end

      @display = display
    end

    def display_name
      @display || @doge_alias&.id || @doge_alias
    end

    def template
      return text -> { '' } if @doge_alias.nil?

      html lambda {
        <<~HTML.chomp
          <a class="link-hover" href="/people/aliases##{text -> { @doge_alias.id }}">#{text -> { display_name }}</a>
        HTML
      }
    end
  end
end
