# frozen_string_literal: true

module Atoms
  # Renders a move label for a position
  class AgencyPositionMoveLabel < Bridgetown::Component
    def initialize(position:, agency:, icon_only: false)
      super()
      @position = position
      @agency = agency
      @icon_only = icon_only
    end

    def destination
      render AgencyLink.new(@position.agency)
    end

    def move_icon
      html lambda {
        if @position.type == 'detailed'
          if @position.agency == @agency || @position.agency.parent == @agency
            render Atoms::Icon.new('detailed_left')
          else
            render Atoms::Icon.new('detailed')
          end
        elsif @position.type == 'internal'
          render Atoms::Icon.new('internal_transfer')
        elsif %w[appointed consultant].include?(@position.type)
          render Atoms::Icon.new('appointed')
        else
          render Atoms::Icon.new(@position.type)
        end
      }
    end

    def left_agency_label
      return if @icon_only

      unless @position.type == 'detailed' && (@position.agency == @agency || @position.agency.parent == @agency) \
             && @position.agency != @agency
        return
      end

      html lambda {
        <<~HTML.chomp
          #{render Atoms::AgencyLink.new(@position.agency)}#{text -> { ' ' }}
        HTML
      }
    end

    def right_agency_label
      return if @icon_only

      if @position.type == 'detailed'
        if @position.agency == @agency || @position.agency.parent == @agency
          if @position.from_agency_id
            render Atoms::AgencyLink.new(@position.from_agency)
          else
            text -> { '???' }
          end
        else
          render Atoms::AgencyLink.new(@position.agency)
        end
      elsif %w[internal appointed consultant converted].include?(@position.type)
        render Atoms::AgencyLink.new(@position.agency)
      end
    end

    def template
      html lambda {
        <<~HTML.chomp
          <span class="md:text-nowrap">#{html -> { left_agency_label }}#{html -> { move_icon }} #{html -> { right_agency_label }}</span>
        HTML
      }
    end
  end
end
