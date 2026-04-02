# frozen_string_literal: true

module Atoms
  # Renders a move label for a position
  class PositionMoveLabel < Bridgetown::Component
    def initialize(position:, show_dest: true)
      super()
      @position = position
      @agency = @position.agency
      @show_dest = show_dest
    end

    def destination
      render AgencyLink.new(@agency) if @show_dest
    end

    def move_icon
      html lambda {
        if @position.from_agency_id
          if @position.type == 'internal'
            '<i class="fa-sharp fa-solid fa-arrows-left-right"></i>'
          else
            '<i class="fa-sharp fa-solid fa-arrow-right"></i>'
          end
        elsif %w[appointed consultant].include?(@position.type)
          '<i class="fa-sharp fa-solid fa-person-to-door"></i>'
        elsif @position.type == 'promotion'
          '<i class="fa-sharp fa-solid fa-arrow-up"></i>'
        elsif @position.type == 'demotion'
          '<i class="fa-sharp fa-solid fa-arrow-down"></i>'
        elsif @position.type == 'converted'
          '<i class="fa-sharp fa-solid fa-person-shelter"></i>'
        else
          ''
        end
      }
    end

    def from_agency_label
      return unless @position.from_agency_id

      html lambda {
        <<~HTML
          #{render AgencyLink.new(@position.from_agency)}#{text -> { '?' if @position.from_truth == 'guessed' }}#{text -> { ' ' }}
        HTML
      }
    end

    def other_move_label
      html -> { "#{html -> { other_move_icon }} #{html -> { destination }}" }
    end

    def template
      html lambda {
        <<~HTML
          <span class="md:text-nowrap">#{html -> { from_agency_label }}#{html -> { move_icon }} #{html -> { destination }}</span>
        HTML
      }
    end
  end
end
