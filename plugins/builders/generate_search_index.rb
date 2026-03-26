# frozen_string_literal: true

require 'json'
require 'sanitize'

module Builders
  # Save out a static API
  class GenerateSearchIndex < SiteBuilder
    def person_record(person)
      {
        id: person.name,
        type: 'Person',
        title: person.name,
        name: person.name,
        content: Sanitize.fragment(person.linkified_blurb),
        url: person.page_url
      }
    end

    def agency_record(agency)
      title = agency.name
      title += " (#{agency.short_name})" if agency.short_name =~ /^[A-Z]+$/

      {
        id: agency.id,
        title: title,
        type: 'Agency',
        agency: agency.short_name,
        content: Sanitize.fragment(agency.linkified_blurb),
        url: agency.page_url
      }
    end

    def event_record(event)
      agencies_list = event.agencies.map(&:short_name).join(', ')
      {
        id: event.id,
        type: 'Event',
        title: "Event #{event.date} #{agencies_list}",
        agency: agencies_list,
        name: (event.people.map(&:name) + event.doge_aliases.map(&:id)).join(','),
        content: Sanitize.fragment(event.linkified_text),
        url: "/all/events##{event.id}"
      }
    end

    def system_record(govt_system)
      title = govt_system.name
      title += " (#{govt_system.acronym})" if govt_system.acronym

      {
        id: govt_system.id,
        type: 'System',
        title: title,
        content: Sanitize.fragment(govt_system.description),
        name: govt_system.system_roles.map(&:name).uniq.join(', '),
        agency: ([govt_system.agency_id] + govt_system.system_roles.map(&:agency_id)).uniq.join(', '),
        url: "/all/systems##{govt_system.id}"
      }
    end

    def doc_record(document)
      return unless document.data&.title && document.data.index_for_search

      {
        id: document.data.slug,
        type: 'Page',
        title: document.data.title,
        url: document.relative_url,
        content: Sanitize.fragment(document.content)
      }
    end

    def generate_out
      out = []
      out += Person.all.map { |p| person_record(p) }
      out += Agency.all.map { |a| agency_record(a) }
      out += Event.all.map { |e| event_record(e) }
      out += GovtSystem.all.map { |s| system_record(s) }
      out += site.resources.map { |r| doc_record(r) }
      out.compact
    end

    def build
      hook :site, :post_write do |_|
        out = generate_out
        file = site.in_destination_dir('search-index.json')
        File.write(file, JSON.pretty_generate(out))
      end
    end
  end
end
