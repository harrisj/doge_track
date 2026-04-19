# frozen_string_literal: true

module Grid
  # A single row in the agency person table
  class AgencyPersonPositions < Bridgetown::Component
    include ExtraMixins

    def initialize(agency:, person:, positions:)
      super()
      @agency = agency
      @person = person
      @positions = positions
    end

    def exit_label
      last_position = @positions.last

      if @person.is_a?(Person) && @person&.govt_exit_date
        <<~HTML
          <div class="font-semibold"><span class="text-base-content/75">#{render Atoms::Icon.new('offboard')} Left govt</span> <span class="my-date">#{render Atoms::DateLabel.new(@person.govt_exit_date)}</span> (#{text -> { @person.govt_exit_truth }})</div>
        HTML
      elsif @last_position && @last_position.end_date.to_s =~ /^\d{4}-\d{2}-\d{2}$/
        <<~HTML
          <div>#{render Atoms::Icon.new('offboard')} #{render Atoms::PositionEndTypeLabel.new(position: last_position)} <span class="my-date">#{render Atoms::DateLabel.new(last_position.end_date)}</span></div>
        HTML
      end
    end

    def position_date_range(pos)
      if pos.start_date
        render Atoms::DateRange.new(start_date: pos.start_date, end_date: pos.end_date)
      else
        html -> { '<em>date unknown</em>' }
      end
    end

    def sources
      @positions.map(&:sources).flatten
    end

    def extra_section
      extra_table <<~HTML
        #{html -> { sources_extra(self) }}
      HTML
    end

    def template
      html lambda {
        <<~HTML
           <details class="collapse">
             <summary class="collapse-title p-0">
               <div class="flex flex-col space-y-0.5">
              #{ html_map(@positions) do |pos|
                   <<~HTML
                     <div>#{render Atoms::AgencyPositionMoveLabel.new(position: pos, agency: @agency)} #{html -> { position_date_range(pos) }} #{render Molecules::PositionSummary.new(position: pos, agency: @agency)}</div>
                   HTML
                 end
              }
              #{html -> { exit_label }}
          </div></summary>

            #{html -> { extra_section }}
          </details>
        HTML
      }
    end
  end
end
