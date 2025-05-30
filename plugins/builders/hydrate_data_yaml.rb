# frozen_string_literal: true

module Builders
  # This iterates through the data.yaml objects and links them to each other
  class HydrateDataYaml < SiteBuilder
    def lookup_person(name)
      site.data.people.find { |p| p.name == name } || raise("Couldn't find person #{name}")
    end

    def lookup_agency(agency_id)
      site.data.agencies.find { |a| a.id == agency_id } || raise("Couldn't find agency #{agency_id}")
    end

    def lookup_alias(alias_id)
      site.data.aliases.find { |a| a.id == alias_id } || raise("Couldn't find alias #{alias_id}")
    end

    def lookup_event(event_id)
      site.data.events.find { |e| e.id == event_id } || raise("Couldn't find event #{event_id}")
    end

    def lookup_position(pos_id)
      site.data.positions.find { |p| p.id == pos_id } || raise("Couldn't find position #{pos_id}")
    end

    def hydrate_agencies(site)
      site.data.agencies.each do |ag|
        ag.positions = ag.position_ids.map { |p_id| lookup_position(p_id) } || []
        ag.children = ag.children.map { |a_id| lookup_agency(a_id) } || []
        ag.events = ag.event_ids.map { |e_id| lookup_event(e_id) } || []
        ag.questions = []
      end
    end

    def hydrate_documents(site)
      site.data.documents.each do |doc|
        doc.person = lookup_person(doc.name) unless doc.name.blank?
        doc.alias = lookup_alias(doc.alias) unless doc.alias.blank?
      end
    end

    def hydrate_aliases(site)
      site.data.aliases.each do |a|
        a.events = a.event_ids.map { |e_id| lookup_event(e_id) }
        a.positions = a.position_ids.map { |p_id| lookup_position(p_id) }
        a.questions = []
      end
    end

    def hydrate_positions(site)
      site.data.positions.each do |pos|
        pos.person = lookup_person(pos.name) unless pos.name.nil?
        pos.questions = []
        pos.agency = lookup_agency(pos.agency_id) unless pos.agency_id.blank?
        pos.from_agency = lookup_agency(pos.from_agency_id) unless pos.from_agency_id.blank?
      end
    end

    def hydrate_events(site)
      site.data.events.each do |event|
        event.people = event.names.map { |n| lookup_person(n) } unless event.names.nil?
        event.agencies = event.agency_ids.map { |a| lookup_agency(a) } unless event.agency_ids.nil?
        event.questions = []
      end
    end

    def hydrate_people(site)
      site.data.people.each do |person|
        person.positions = person.position_ids.map { |p| lookup_position(p) } || []
        person.events = person.event_ids.map { |e| lookup_event(e) } || []
        person.questions = []
      end
    end

    def hydrate_questions(site)
      site.data.questions.each do |q|
        unless q.name.blank?
          person = lookup_person(q.name)
          person.questions.append(q)
        end

        unless q.agency_id.blank?
          agency = lookup_agency(q.agency_id)
          agency.questions ||= []
          agency.questions.append(q)
        end

        unless q.alias.blank?
          doge_alias = lookup_alias(q.alias)
          doge_alias.questions ||= []
          doge_alias.questions.append(q)
        end

        unless q.event_id.blank?
          event = lookup_event(q.event_id)
          event.questions ||= []
          event.questions.append(q)
        end

        next if q.position_id.blank?

        position = lookup_position(q.position_id)
        position.questions.append(q)
      end
    end

    def build
      hook :site, :post_read do |site|
        hydrate_aliases(site)
        hydrate_documents(site)
        hydrate_events(site)
        hydrate_positions(site)
        hydrate_people(site)
        hydrate_agencies(site)
        hydrate_questions(site)
      end
    end
  end
end
