# frozen_string_literal: true

require 'sequel'

DB_PATH = File.join(File.dirname(__FILE__), '..', 'doge.sqlite')
DB = Sequel.sqlite(DB_PATH)

DB.create_table! :agencies do
  string :id, primary_key: true
  string :name, null: false
  string :slug, null: false, unique: true
  boolean :doge_base, null: false, default: false
  string :parent_id
end

DB.create_table! :doge_aliases do
  string :id, primary_key: true
  string :agency_id
  string :name
  text :evidence
end

DB.create_table! :positions do
  string :id, primary_key: true
  string :type, null: false
  string :agency_id
  string :name
  string :doge_alias_id
  string :from_agency_id

  string :start_date
  string :start_date_truth
  string :end_date
  string :end_date_truth
  string :nte_date
  string :nte_date_truth
  string :signed_date
  string :description
  string :fuzz
  string :appt_type_code
  string :appt_type
  string :pay_grade
  string :salary
  string :pd_code
  string :title
  string :series
  boolean :supervisory
  string :office
  string :source
  boolean :reimbursed
  string :reimbursement_amount
  string :comment
  string :qualifications
end

DB.create_table! :people do
  string :name, primary_key: true
  string :sort_name, null: false
  string :slug, null: false, unique: true
  integer :age
  string :background
  string :category, null: false, default: 'unknown'
  boolean :own_page, null: false, default: false
end

DB.create_table! :events do
  string :id, primary_key: true
  string :type, null: false
  string :date, null: false
  string :sort_date, null: false
  string :time
  string :text, null: false
  string :fuzz
  string :comment
  string :source, null: false
  string :source_title
  string :source_name
  string :case_no
end

DB.create_table! :cases do
  string :case_no, primary_key: true
  string :name, null: false
  string :description, null: false
  date :date_filed, null: false
  string :link, null: false
  string :status
end

DB.create_table! :govt_systems do
  string :id, primary_key: true
  string :name, null: false
  string :type, null: false, default: 'unknown'
  string :description
  string :comment
  string :category
  string :population
  string :risk
  string :link
  string :pia
  string :sorn
  string :agency_id
end

DB.create_table! :system_roles do
  string :id, primary_key: true
  string :govt_system_id
  string :name
  string :doge_alias_id
  string :agency_id
  string :type, null: false
  string :date_requested
  string :date_req_truth
  string :date_granted
  string :date_grant_truth
  string :ao_name
  string :ao_type
  string :bypassed
  string :date_last_used
  string :date_used_truth
  string :date_revoked
  string :date_revoked_truth
  string :date_nte
  string :date_nte_truth
  string :last_accessed
  boolean :never_accessed, null: false, default: false
  string :source
  string :comment
end

DB.create_table! :doge_aliases_events do
  foreign_key :doge_alias_id, :doge_aliases, type: :string
  foreign_key :event_id, :events, type: :string
end

DB.create_table! :agencies_cases do
  foreign_key :agency_id, :agencies, null: false, type: :string
  foreign_key :case_no, :cases, null: false, type: :string
  unique %i[agency_id case_no]
end

DB.create_table! :agencies_events do
  foreign_key :agency_id, :agencies, null: false, type: :string
  foreign_key :event_id, :events, null: false, type: :string
  unique %i[agency_id event_id]
end

DB.create_table! :events_people do
  foreign_key :name, :people, null: false, type: :string
  foreign_key :event_id, :events, null: false, type: :string
  unique %i[name event_id]
end

DB.create_table! :people_positions do
  foreign_key :name, :people, null: false, type: :string
  foreign_key :position_id, :positions, null: false, type: :string
  unique %i[name position_id]
end

DB.create_table! :doge_aliases_positions do
  foreign_key :doge_alias_id, :doge_aliases, null: false, type: :string
  foreign_key :position_id, :positions, null: false, type: :string
  unique %i[position_id doge_alias_id]
end
