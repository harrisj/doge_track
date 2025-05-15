# frozen_string_literal: true

module Builders
  # Defines a collection of Liquid tags aka short-codes for dynamically linking to people/agencies/etc.
  # This lets me change a person's page in the database and have all the links update automatically
  # It does require that the pages.rb script is correct
  class DogeLinks < SiteBuilder
    NO_MATCH_URL_STRING = '#'

    def build
      liquid_tag :person_url, :link_person_url, as_block: false
      liquid_tag :person_link, :link_person_tag, as_block: false
      liquid_tag :agency_url, :link_agency_url, as_block: false
      liquid_tag :agency_link, :link_agency_tag, as_block: false
    end

    def lookup_person(tag, name)
      people = tag.context['site']['data']['pages']['people'].values
      people.find do |p|
        p['name'].downcase == name.downcase || p['slug'] == name || p['sort_name'].downcase == name.downcase
      end
    end

    def lookup_agency(tag, id)
      agencies = tag.context['site']['data']['pages']['agencies'].values

      agencies.find do |a|
        a['id'].downcase == id.downcase || a['slug'].downcase == id.downcase
      end
    end

    def link_person_url(attributes, tag)
      name, = attributes.split(',').map(&:strip)
      person = lookup_person(tag, name)
      return person['path'] if person && person['path'] && person['path'] != 'none'

      NO_MATCH_URL_STRING
    end

    def link_person_tag(attributes, tag)
      name, = attributes.split(',').map(&:strip)
      url = link_person_url(attributes, tag)

      return name if url == NO_MATCH_URL_STRING

      person = lookup_person(name, tag)
      # FIXME: Options for setting class and also overriding them
      "<a href=\"#{url}\">#{person.name}</a>"
    end

    def link_agency_url(attributes, tag)
      id, = attributes.split(',').map(&:strip)
      agency = lookup_agency(tag, id)
      return agency['path'] if agency && agency['path'] && agency['path'] != 'none'

      NO_MATCH_URL_STRING
    end

    def link_agency_tag(attributes, tag)
      id, = attributes.split(',').map(&:strip)
      url = link_agency_url(attributes, tag)

      return id if url == NO_MATCH_URL_STRING

      "<a href=\"#{url}\">#{id}</a>"
    end
  end
end
