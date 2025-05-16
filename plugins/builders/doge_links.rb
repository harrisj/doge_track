# frozen_string_literal: true

module Builders
  # Defines a collection of Liquid tags aka short-codes for dynamically linking to people/agencies/etc.
  # This lets me change a person's page in the database and have all the links update automatically
  # It does require that the pages.rb script is correct
  class DogeLinks < SiteBuilder
    include Bridgetown::LiquidExtensions
    NO_MATCH_URL_STRING = '#'

    def build
      liquid_tag :person_url, :wrap_link_person_url, as_block: false
      liquid_tag :person_link, :wrap_link_person_tag, as_block: false

      liquid_tag :agency_url, :wrap_link_agency_url, as_block: false
      liquid_tag :agency_link, :wrap_link_agency_tag, as_block: false

      liquid_filter :agency_links do |agency_ids|
        agency_ids.map { |agency_id| link_agency_tag(agency_id, filters_context) }.join(', ')
      end
    end

    def lookup_person(context, name)
      return nil if name.nil?
      raise 'Nil Context' if context.nil?

      begin
        value = lookup_variable(context, name)
        name = value unless value.nil?
      rescue NoMethodError
        return nil
      end

      people = context['site']['data']['pages']['people'].values

      people.find do |p|
        p['name'].downcase == name.downcase || p['slug'] == name || p['sort_name'].downcase == name.downcase
      end
    end

    def lookup_agency(context, agency_id)
      return nil if agency_id.nil?
      raise 'Nil Context' if context.nil?

      value = lookup_variable(context, agency_id)
      agency_id = value unless value.nil?

      agencies = context['site']['data']['pages']['agencies'].values

      agencies.find do |a|
        a['id'].downcase == agency_id.downcase || (a['slug'] && a['slug'].downcase == agency_id.downcase)
      end
    end

    def wrap_link_person_url(attributes, tag)
      link_person_url(attributes, tag.context)
    end

    def link_person_url(attributes, context)
      name, = attributes.split(',').map(&:strip)

      person = lookup_person(context, name)
      return person['path'] if person && person['path'] && person['path'] != 'none'

      NO_MATCH_URL_STRING
    end

    def wrap_link_person_tag(attributes, tag)
      link_person_tag(attributes, tag.context)
    end

    def link_person_tag(attributes, context)
      name, = attributes.split(',').map(&:strip)
      url = link_person_url(attributes, context)

      # In case name is nil
      return name || '' if url == NO_MATCH_URL_STRING

      person = lookup_person(context, name)
      # FIXME: Options for setting class and also overriding them
      "<a href=\"#{url}\">#{person.name}</a>"
    end

    def wrap_link_agency_url(attributes, tag)
      link_agency_url(attributes, tag.context)
    end

    def link_agency_url(attributes, context)
      agency_id, = attributes.split(',').map(&:strip)
      agency = lookup_agency(context, agency_id)
      return agency['path'] if agency && agency['path'] && agency['path'] != 'none'

      NO_MATCH_URL_STRING
    end

    def wrap_link_agency_tag(attributes, tag)
      link_agency_tag(attributes, tag.context)
    end

    def link_agency_tag(attributes, context)
      agency_id, = attributes.split(',').map(&:strip)
      url = link_agency_url(attributes, context)

      return agency_id || '' if url == NO_MATCH_URL_STRING

      agency = lookup_agency(context, agency_id)
      "<a href=\"#{url}\">#{agency.id}</a>"
    end
  end
end
