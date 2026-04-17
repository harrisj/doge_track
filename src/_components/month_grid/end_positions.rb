# frozen_string_literal: true

module MonthGrid
  # A representation of the start positions
  class EndPositions < Bridgetown::Component
    def initialize(positions:)
      super()
      @positions = positions
    end

    def position_text(person, positions)
      if person.govt_exit_date
        <<~HTML.chomp
          #{render Atoms::PersonLink.new(person)} leaves govt. service (#{render Atoms::AgenciesList.new(positions.map(&:agency), style: :sentence)})
        HTML
      elsif positions.one?
        <<~HTML.chomp
          #{render Atoms::PersonLink.new(person)} leaves #{text -> { positions[0].title }} role at #{render Atoms::AgencyLink.new(positions[0].agency)}
        HTML
      else
        <<~HTML.chomp
          #{render Atoms::PersonLink.new(person)} leaves positions at #{render Atoms::AgenciesList.new(positions.map(&:agency), style: :sentence)}
        HTML
      end
    end

    def template
      return text -> { '' } if @positions.nil? || @positions.empty?

      by_person = @positions.group_by(&:person)

      html lambda {
        html_map(by_person) do |grp|
          person = grp[0]
          positions = grp[1]

          if person.nil?
            text -> { '' }
          else
            <<~HTML
              <div class="text-center"><i class="fa-sharp fa-solid fa-arrow-left-from-bracket"></i></div>
              <div>#{html -> { position_text(person, positions) }}</div>
            HTML
          end
        end
      }
    end
  end
end
