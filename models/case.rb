# frozen_string_literal: true

require 'sequel'

# Represents a court case
class Case < Sequel::Model
  one_to_many :events, key: :case_no
  many_to_many :agencies, left_key: :case_no, right_key: :agency_id
end
