# frozen_string_literal: true

# # frozen_string_literal: true

# module Atoms
#   # A link to a person's page
#   class DogeExitLabel < Bridgetown::Component
#     def initialize(position:)
#       super()
#       @position = position
#       @person = position.person
#     end

#     def left_doge_label?
#       @person && !@person.govt_exit_date.nil? && @person.govt_exit_date == position.end_date
#     end

#     def left_doge_label
#       <<~HTML
#         <strong>Left DOGE#{ text -> {' (guessed)' if @person.govt_exit_truth == 'guessed'}}</strong>
#       HTML
#     end

#     def other_end_label
#       render PositionEndTypeLabel.new(position: @position)
#     end

#     def template
#       html lambda {
#         <<~HTML
#           <div>
#          #{ html -> { left_doge_label? ? left_doge_label : position_end_type_label : other_end_label } }
#           </div>
#         HTML
#       }
#     end
#   end
# end
