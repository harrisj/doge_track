# frozen_string_literal: true

require 'yaml'
require 'date'

publishers_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'publishers.yaml')
publishers = YAML.unsafe_load(File.read(publishers_file), symbolize_names: true)

File.join(File.dirname(__FILE__), '..', 'raw_data', 'sources.yaml')
sources = YAML.unsafe_load(File.read(publishers_file), symbolize_names: true)

interagency_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'interagency.yaml')
agencies_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'agencies.yaml')

interagency = YAML.unsafe_load(File.read(interagency_file), symbolize_names: true)
agencies = YAML.unsafe_load(File.read(agencies_file), symbolize_names: true)

agencies.each do |agency|
  agency[:events].each do |event|
    source_from_event(event, sources, publishers)
  end
end

interagency.each do |event|
  source_from_event(event, sources, publishers)
end
