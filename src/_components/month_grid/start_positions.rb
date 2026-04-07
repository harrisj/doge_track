# frozen_string_literal: true

module MonthGrid
  # A representation of the start positions
  class StartPositions < Bridgetown::Component
    def initialize(positions:)
      super()
      @positions = positions
    end

    def by_agency_grouping(types:, icon:, verb:, verb_plural:)
      by_agency = @positions.select { |pos| types.include?(pos.type) && pos.person }.group_by(&:agency_id)

      return unless by_agency.any?

      <<~HTML
        <div class="text-center"><i class="fa-sharp fa-solid #{text -> { icon }}"></i></div>
        <div>
            #{ html_map(by_agency) do |grp|
              agency_id, positions = grp
              people = positions.sort_by { |pos| pos.person.sort_name }.map(&:person)
              sentence_verb = people.one? ? verb : verb_plural
              <<~HTML
                #{render Atoms::PeopleList.new(people, style: :sentence)} #{text -> { sentence_verb }} #{render Atoms::AgencyLink.new(agency_id)}#{text -> { '. ' }}
              HTML
            end
            }
        </div>
      HTML
    end

    def to_position(types:, icon:, verb:, conjunction:)
      positions = @positions.select { |pos| types.include?(pos.type) }
      return unless positions.any?

      html lambda {
        html_map(positions) do |position|
          title_clause = position.title ? " #{conjunction} #{position.title}" : ''
          <<~HTML.chomp
            <div class="text-center"><i class="fa-sharp fa-solid #{text -> { icon }}"></i></div>
            <div>#{render Atoms::PersonLink.new(position.person)} #{text -> { verb }}#{text -> { title_clause }} at #{render Atoms::AgencyLink.new(position.agency)}</div>
          HTML
        end
      }
    end

    def starts_section
      by_agency_grouping(types: %w[appointed consultant], icon: 'fa-person-to-door', verb: 'starts at',
                         verb_plural: 'start at')
    end

    def details_section
      by_agency_grouping(types: ['detailed'], icon: 'fa-arrow-right', verb: 'is detailed to',
                         verb_plural: 'are detailed to')
    end

    def converts_section
      to_position(types: ['converted'], icon: 'fa-person-shelter', verb: 'converted to permanent position',
                  conjunction: 'as')
    end

    def promotions_section
      to_position(types: ['promotion'], icon: 'fa-arrow-up', verb: 'promoted', conjunction: 'to')
    end

    def demotions_section
      to_position(types: ['demotion'], icon: 'fa-arrow-down', verb: 'demoted', conjunction: 'to')
    end

    def template
      html lambda {
        <<~HTML
          #{html -> { starts_section }}
          #{html -> { details_section }}
          #{html -> { converts_section }}
          #{html -> { promotions_section }}
          #{html -> { demotions_section }}
        HTML
      }
    end
  end
end
