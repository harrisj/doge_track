# frozen_string_literal: true

require_relative '../../data/scripts/models'
require 'json'

module Builders
  # Save out a static API
  class GenerateApi < SiteBuilder
    def api_path(path)
      "https://dogetrack.info/api/#{path}"
    end

    def agency_ref(agency)
      {
        id: agency.id,
        name: agency.name,
        short_name: agency.short_name,
        parent_id: agency.parent_id,
        path: api_path("agencies/#{agency.slug}.json")
      }
    end

    def person_ref(person)
      {
        name: person.name,
        sort_name: person.sort_name,
        slug: person.slug,
        path: api_path("people/#{person.slug}.json")
      }
    end

    def event_record(event)
      {
        id: event.id,
        type: event.type,
        date: event.date,
        sort_date: event.date,
        text: event.text,
        fuzz: event.fuzz,
        comment: event.comment,
        source: event.source,
        source_name: event.source_name,
        case_no: event.case_no,
        agencies: event.agencies.map { |a| agency_ref(a) },
        people: event.people.map { |p| person_ref(p) }
      }
    end

    def position_record(position)
      out = position.to_hash.except(:agency, :from_agency, :name)
      out[:agency] = agency_ref(position.agency)
      out[:from_agency] = position.from_agency ? agency_ref(position.from_agency) : nil
      out[:person] = position.person ? person_ref(position.person) : nil
      out
    end

    def generate_agencies_json
      file = site.in_destination_dir('api', 'agencies.json')
      agencies = Agency.eager(:events, :positions).order_by('id').all

      out = agencies.map do |a|
        h = agency_ref(a)
        h[:num_events] = a.events.count
        h[:num_positions] = a.positions.count
        h[:num_doge] = a.positions.map { |p| p.name || p.doge_alias_id }.uniq.count
        h
      end

      File.write(file, JSON.pretty_generate(out))

      # Now write each agency
      agencies.each do |a|
        h = agency_ref(a)
        h[:events] = a.events.map { |e| event_record(e) }
        h[:positions] = a.positions.map { |p| position_record(p) }

        file = site.in_destination_dir('api', 'agencies', "#{a.slug}.json")
        FileUtils.mkdir_p(File.dirname(file))
        File.write(file, JSON.pretty_generate(h))
      end
    end

    def generate_people_json
      file = site.in_destination_dir('api', 'people.json')
      people = Person.eager(:events, :positions).order_by('sort_name').all

      out = people.map do |person|
        h = person_ref(person)
        h[:category] = person.category
        h[:skill] = person.skill
        h[:govt_start_date] = person.positions.any? ? person.positions.first.start_date : nil
        h[:govt_exit_date] = person.govt_exit_date
        h[:num_events] = person.events.count
        h[:num_positions] = person.positions.count
        h[:agencies] = person.positions.map(&:agency).uniq.map { |a| agency_ref(a) }
        h
      end

      File.write(file, JSON.pretty_generate(out))

      people.each do |person|
        h = person.to_hash
        h[:events] = person.events.map { |e| event_record(e) }
        h[:positions] = person.positions.map { |p| position_record(p) }

        file = site.in_destination_dir('api', 'people', "#{person.slug}.json")
        FileUtils.mkdir_p(File.dirname(file))
        File.write(file, JSON.pretty_generate(h))
      end
    end

    def build
      hook :site, :post_write do |_|
        # FIXME: Don't trigger refresh in some cases?

        generate_agencies_json
        generate_people_json
      end
    end
  end
end
