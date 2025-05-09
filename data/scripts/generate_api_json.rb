# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative 'models'

OUTPUT_DIR = File.join(File.dirname(__FILE__), '..', '..', 'api')

def events_for_output(events)
  events = events.map do |e|
    e_out = e.to_hash
    e_out['agencies'] = e.agencies.map { |a| a.to_hash.slice(:id, :slug, :name) }
    e_out['people'] = e.people.map { |x| x.to_hash.slice(:slug, :name, :sort_name) }

    e_out['aliases'] = []
    e.aliases.each do |a|
      if a.person
        existing_record = e_out['people'].find { |p| p[:name] == a.name }
        existing_record[:alias] = a.id
      else
        e_out['aliases'].append(a.id)
      end
    end

    e_out
  end

  events.sort_by { |e| e[:sort_date] }
end

def generate_agencies_json
  agencies = Agency.all
  output_path = File.join(OUTPUT_DIR, 'agencies.json')

  out = agencies.map(&:to_hash)

  File.write(output_path, JSON.pretty_generate(out))

  output_dir = output_path = File.join(OUTPUT_DIR, 'agencies')
  FileUtils.mkdir_p(output_dir)

  agencies.each do |a|
    out = a.to_hash
    out['events'] = events_for_output(a.events)

    output_path = File.join(output_dir, "#{a.slug}.json")
    File.write(output_path, JSON.pretty_generate(out))
  end
end

generate_agencies_json if __FILE__ == $PROGRAM_NAME
