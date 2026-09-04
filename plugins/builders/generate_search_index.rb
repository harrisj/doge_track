# frozen_string_literal: true

require 'json'
require 'sanitize'

module Builders
  # Save out a static API
  class GenerateSearchIndex < SiteBuilder
    def person_record(person)
      first_agency = person.first_agency&.id
      start_date = person.start_date&.strftime('%-m/%d/%y')
      end_date = person.govt_exit_date ? person.govt_exit_date.strftime('%-m/%d/%y') : ''
      agency_count = person.positions.filter { |p| p.agency.parent.nil? }.map(&:agency_id).uniq.count
      other_agency_str = first_agency && agency_count > 1 ? "(+#{agency_count - 1} other agencies)" : nil
      date_range = start_date ? "#{start_date}-#{end_date}" : nil

      {
        id: person.name,
        type: 'Person',
        title: person.name,
        icon: 'person',
        name: person.name,
        content: [first_agency, date_range, other_agency_str].compact.join(' '),
        # content: Sanitize.fragment(person.linkified_blurb),
        url: person.page_url
      }
    end

    def position_verb(position)
      return '' if position.nil?

      case position.type
      when 'other'
        ''
      when 'detailed'
        detail_type = position.from_truth == 'guessed' ? 'likely detailed' : 'detailed'
        if position.from_agency
          "#{detail_type} from #{position.from_agency.short_name} to #{position.agency.short_name}"
        else
          detail_type
        end
      when 'promotion'
        position.title ? 'promoted to' : 'promoted'
      when 'demotion'
        position.title ? 'demoted to' : 'demoted'
      when 'converted'
        'converted to permanent position'
      when 'internal'
        'internal xfer'
      when 'unknown'
        'unknown start type'
      else
        'started'
      end
    end

    def position_record(position)
      return unless position.name

      verb = position_verb(position)

      out = [verb, position.title]

      out << position.pay_grade
      out << 'excepted' if position.excepted

      if position.salary
        out << if position.salary == '$0'
                 'volunteer'
               else
                 position.salary
               end
      end

      out.append(position.reimbursement_amount) if position.reimbursement_amount

      out.compact!
      return unless out.any?

      summary = out.join(', ')

      {
        id: position.id,
        title: position.name.to_s,
        type: 'Position',
        agency: position.agency.short_name,
        content: summary,
        url: "/names/#{position.person.slug}##{position.id}"
      }
    end

    def agency_record(agency)
      title = agency.name
      title += " (#{agency.short_name})" if agency.short_name =~ /^[A-Z]+$/

      num_people = agency.all_positions(internal_xfers: true).map(&:name).uniq.count
      num_events = agency.all_events.count
      num_systems = agency.all_systems.count

      {
        id: agency.id,
        title: title,
        alt_title: agency.short_name,
        type: 'Agency',
        icon: 'agency',
        agency: agency.short_name,
        content: "#{num_people} people, #{num_systems} systems, #{num_events} events",
        # content: Sanitize.fragment(agency.linkified_blurb),
        url: agency.page_url
      }
    end

    def event_record(event)
      agencies_list = event.agencies.map(&:short_name).join(', ')
      {
        id: event.id,
        type: 'Event',
        title: "#{event.date} #{agencies_list}",
        icon: event.type,
        agency: agencies_list,
        name: (event.people.map(&:name) + event.doge_aliases.map(&:id)).join(','),
        content: Sanitize.fragment(event.linkified_text),
        url: "/timeline/#{event.date.strftime('%Y/%m')}##{event.id}"
      }
    end

    def system_record(govt_system)
      title = govt_system.name
      title += " (#{govt_system.acronym})" if govt_system.acronym

      agencies = ([govt_system.agency_id] + govt_system.system_roles.map(&:agency_id)).uniq
      names = govt_system.system_roles.map(&:name).uniq

      {
        id: govt_system.id,
        type: 'System',
        title: title,
        alt_title: govt_system.acronym,
        icon: 'system_grant',
        # content: Sanitize.fragment(govt_system.description),
        content: "#{agencies.join(', ')} #{names.count} people: #{Sanitize.fragment(govt_system.description)}",
        name: names.join(', '),
        agency: agencies.join(', '),
        url: govt_system.page_url
      }
    end

    def doc_record(document)
      return unless document.data&.title && document.data.index_for_search && document.data.description

      # html_doc = Nokogiri::HTML(document.content)
      # html_doc.css('div.not-prose').remove

      {
        id: document.data.slug,
        type: 'Page',
        title: document.data.title,
        icon: 'website',
        url: document.relative_url,
        content: document.data.description
      }
    end

    def generate_out
      out = []
      out += Person.all.map { |p| person_record(p) }
      # out += Position.all.map { |p| position_record(p) }
      out += Agency.all.map { |a| agency_record(a) }
      out += Event.all.map { |e| event_record(e) }
      out += GovtSystem.all.map { |s| system_record(s) }
      out += site.resources.map { |r| doc_record(r) }
      out.compact
    end

    def build
      hook :site, :post_write do |_|
        out = generate_out
        out.each do |rec|
          if rec[:icon]
            rec[:ic] = Atoms::Icon.new(rec[:icon]).icon_css
            rec.delete(:icon)
          end
        end
        file = site.in_destination_dir('search-index.json')
        File.write(file, JSON.generate(out))
      end
    end
  end
end
