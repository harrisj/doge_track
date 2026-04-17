# frozen_string_literal: true

module Table
  # A table of when DOGE made first contact at agencies
  class AgencyFirstContacts < Bridgetown::Component
    def initialize(agencies:)
      super()

      unless agencies.is_a?(Array) && agencies.all?(Agency)
        raise ArgumentError,
              'AgencyFirstContacts must be passed an array of agencies'
      end

      @agency_contacts = agencies.map do |a|
        { agency: a,
          id: a.id,
          child_ids: a.children.map(&:id),
          children: a.children,
          short_name: a.short_name,
          name: a.name,
          first_contact: '',
          people: [] }
      end

      @agency_contacts.each do |ac|
        positions = ac[:agency].all_positions.reject { |pos| pos.name.nil? || pos.start_date.nil? }
        next unless positions.any?

        ac[:first_contact] = positions.first[:start_date]
        ac[:sort_date] = positions.first[:sort_date]
        ac[:people_names] = positions
                            .reject { |pos| pos.name.nil? }
                            .sort_by { |pos| pos.person.sort_name }
                            .map(&:name)
                            .uniq
      end

      @agency_contacts.reject! { |ac| ac[:sort_date].nil? }
      @agency_contacts.sort_by! { |ac| ac[:sort_date] }
      @agency_contacts.each { |ac| ac[:people].sort_by!(&:sort_name) }
    end
  end
end
