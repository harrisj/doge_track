# frozen_string_literal: true

module Atoms
  # A link to a person's page
  class PositionEndTypeLabel < Bridgetown::Component
    def initialize(position:)
      super()
      @position = position
    end

    def template
      html lambda {
        case pos.end_type
        when 'detail_ended'
          'detail ended'
        when 'replaced'
          if pos.replaced_by
            <<~HTML.chomp
              <a class="link-hover sm:text-nowrap" href="##{text -> { @position.replaced_by }}">
              <i class="fa-sharp fa-solid fa-up-right-from-square"></i> next role</a>"
            HTML
          else
            'replaced'
          end
        when 'resigned'
          'resigned from agency'
        when 'fired'
          <<~HTML.chomp
            <span class="font-bold my-emphasis">fired</span>
          HTML
        when 'unknown'
          ''
        else
          <<~HTML.chomp
            #{text -> { @position.end_type }}
          HTML
        end
      }
    end
  end
end
