# frozen_string_literal: true

require 'yaml'
require 'date'

documents_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'documents.yaml')

documents = YAML.unsafe_load_file(documents_file, symbolize_names: true)

document_ids = {}

documents.each do |doc|
  document_ids[doc[:id]] ||= 0
  document_ids[doc[:id]] += 1
end

duplicate_ids = []
document_ids.each do |k, v|
  duplicate_ids.append(k) if v > 1
end

raise "Duplicate IDs for documents: #{duplicate_ids.join(', ')}" unless duplicate_ids.empty?
