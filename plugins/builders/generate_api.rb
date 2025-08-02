# frozen_string_literal: true

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

    def alias_ref(doge_alias)
      {
        id: doge_alias.id,
        person: doge_alias.person ? person_ref(doge_alias.person) : nil
      }
    end

    def access_record(system_role, include_person: true, include_agency: true, include_system: true)
      out = system_role.to_hash.except(:name, :govt_system_id, :agency_id)
      out[:person] = person_ref(system_role.person) if include_person && system_role.person
      out[:agency] = agency_ref(system_role.agency) if include_agency && system_role.agency
      if include_system && system_role.govt_system
        out[:system] =
          system_record(system_role.govt_system, include_roles: false)
      end

      out
    end

    def system_record(govt_system, include_agency: true, include_roles: true)
      out = govt_system.to_hash.except(:agency_id)
      out[:agency] = agency_ref(govt_system.agency) if include_agency && govt_system.agency

      if include_roles && govt_system.system_roles.any?
        out[:access] = govt_system.system_roles.map do |r|
          access_record(r, include_system: false)
        end
      end

      out
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
        people: event.people.map { |p| person_ref(p) },
        aliases: event.doge_aliases.map { |a| alias_ref(a) }
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
        h[:systems] = a.roles_by_system.map do |govt_system, roles|
          s = system_record(govt_system, include_roles: false, include_agency: false)
          # Need to do this instead of all roles for a system because of SSP and SaaS services
          s[:access] = roles.map { |x| access_record(x, include_system: false, include_agency: false) }
          s
        end

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
        h[:systems_accessed] = person.system_roles.map { |r| access_record(r, include_person: false) }
        h
      end

      File.write(file, JSON.pretty_generate(out))

      people.each do |person|
        h = person.to_hash
        h[:aliases] = person.doge_aliases.map(&:id)
        h[:events] = person.events.map { |e| event_record(e) }
        h[:positions] = person.positions.map { |p| position_record(p) }
        h[:system_access] = person.system_roles.map { |r| access_record(r) }

        file = site.in_destination_dir('api', 'people', "#{person.slug}.json")
        FileUtils.mkdir_p(File.dirname(file))
        File.write(file, JSON.pretty_generate(h))
      end
    end

    def generate_events_json
      # by_month = {}
      events = Event.eager(:agencies, :people, :doge_aliases).order_by('date').all

      out = events.map do |event|
        h = event.to_hash
        h[:people] = event.people.map { |p| person_ref(p) }
        h[:agencies] = event.agencies.map { |a| agency_ref(a) }
        h[:doge_aliases] = event.doge_aliases.map { |a| alias_ref(a) }

        # by_month_key = date.strftime("%Y-%m")
        # by_month[by_month_key] ||= []
        # by_month[by_month_key] << h

        h
      end

      file = site.in_destination_dir('api', 'events.json')
      FileUtils.mkdir_p(File.dirname(file))
      File.write(file, JSON.pretty_generate(out))
    end

    def generate_doge_aliases_json
      aliases = DogeAlias.eager(:agency, :person).order_by('id').all

      out = aliases.map do |doge_alias|
        h = doge_alias.to_hash.except(:linkified_evidence, :name, :agency_id)
        h[:evidence] = h[:evidence].split("\n").map { |x| x.gsub(/^- /, '') }
        h[:person] = doge_alias.person ? person_ref(doge_alias.person) : nil
        h[:agency] = agency_ref(doge_alias.agency)

        h
      end

      file = site.in_destination_dir('api', 'aliases.json')
      File.write(file, JSON.pretty_generate(out))
    end

    def generate_systems_json; end

    def build
      hook :site, :post_write do |_|
        generate_agencies_json
        generate_people_json
        generate_events_json
        generate_systems_json
        generate_doge_aliases_json
      end
    end
  end
end
