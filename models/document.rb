# frozen_string_literal: true

require 'sequel'

# For documents
class Document < Sequel::Model
  many_to_one :person
  many_to_many :positions

  def url
    "/documents/#{file}"
  end
end
