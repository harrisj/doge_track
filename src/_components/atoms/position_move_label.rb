# frozen_string_literal: true

module Atoms
  # Renders a move label for a position
  class PositionMoveLabel < Bridgetown::Component
    def initialize(position:, show_dest: true, show_from: true)
      super()
      @position = position
      @agency = @position.agency
      @show_dest = show_dest
      @show_from = show_from
    end

    def destination
      render AgencyLink.new(@agency) if @show_dest
    end

    def move_icon
      html lambda {
        if @position.from_agency_id
          if @position.type == 'internal'
            render Atoms::Icon.new('internal_transfer')
          else
            render Atoms::Icon.new('detailed')
          end
        elsif %w[appointed consultant].include?(@position.type)
          render Atoms::Icon.new('appointed')
        else
          render Atoms::Icon.new(@position.type)
        end
      }
    end

    def from_agency_label
      return unless @show_from && @position.from_agency_id

      html lambda {
        <<~HTML.chomp
          #{render AgencyLink.new(@position.from_agency)}#{text -> { '?' if @position.from_truth == 'guessed' }}#{text -> { ' ' }}
        HTML
      }
    end

    def other_move_label
      html -> { "#{html -> { other_move_icon }} #{html -> { destination }}" }
    end

    def template
      html lambda {
        <<~HTML.chomp
          <span class="md:text-nowrap">#{html -> { from_agency_label }}#{html -> { move_icon }} #{html -> { destination }}</span>
        HTML
      }
    end
  end
end
