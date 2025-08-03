# frozen_string_literal: true

require 'sequel'

DB_PATH = File.join(File.dirname(__FILE__), '..', 'doge.sqlite')
DB = Sequel.sqlite(DB_PATH)

DB.create_table! :agencies do
  string :id, primary_key: true
  string :name, null: false
  string :slug, null: false, unique: true
  string :page_slug
  string :short_name, null: false, unique: true
  boolean :doge_base, null: false, default: false
  string :blurb
  string :linkified_blurb
  string :parent_id
end

DB.create_table! :doge_aliases do
  string :id, primary_key: true
  string :agency_id
  string :name
  text :evidence
  text :linkified_evidence
end

DB.create_table! :positions do
  string :id, primary_key: true
  string :type, null: false
  string :agency_id
  string :name
  string :doge_alias_id
  string :from_agency_id
  string :from_truth

  string :start_date
  string :start_date_truth
  string :start_source
  string :start_source_name

  string :end_date
  string :end_date_truth
  string :end_source
  string :end_type

  string :sort_date, null: false

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
  boolean :sge
  boolean :excepted
  string :title
  string :title_type
  string :series
  boolean :supervisory
  string :office
  string :source
  string :source_name
  boolean :reimbursed
  string :reimbursement_amount
  string :comment
  string :qualifications
  string :table_note
  string :replaced_by
  string :same_as
end

DB.create_table! :people do
  string :name, primary_key: true
  string :sort_name, null: false
  string :slug, null: false, unique: true
  string :custom_path
  integer :age
  string :skill
  string :category, null: false, default: 'unknown'
  boolean :own_page, null: false, default: false
  string :blurb
  string :linkified_blurb
  string :reporting_notes
  string :comment
  string :govt_exit_date
  string :govt_exit_truth
  string :govt_exit_type
  string :table_note
  string :tech_links
  string :linkedin
end

DB.create_table! :questions do
  string :id, primary_key: true
  string :question, null: false
  string :context
  string :date
  string :answer
  string :answer_date

  string :name
  string :doge_alias_id
  string :case_no
  string :agency_id
  string :govt_system_id
  string :position_id
  string :event_id
end

DB.create_table! :documents do
  string :id, primary_key: true
  string :name
  string :type
  string :alias
  string :date
  string :source
  string :case_no
  string :comment
  string :file
end

DB.create_table! :events do
  string :id, primary_key: true
  string :type, null: false
  string :date, null: false
  string :sort_date, null: false
  string :time
  string :text, null: false
  string :linkified_text
  string :fuzz
  string :comment
  string :source, null: false
  string :source_title
  string :source_name
  string :case_no
  string :system_id
  string :theme
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
  string :acronym
  string :name, null: false
  string :type, null: false, default: 'unknown'
  string :description
  string :comment
  string :category
  string :theme
  string :population
  string :risk
  string :link
  string :pia
  string :sorn
  string :agency_id
  boolean :doge_created, null: false, default: false
  string :doge_modifications
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
  string :ao_title
  string :ao_office
  boolean :ao_doge
  string :ao_truth

  string :bypassed
  string :date_last_used
  string :date_used_truth
  string :date_revoked
  string :date_revoked_truth
  string :date_nte
  string :date_nte_truth
  boolean :never_accessed, null: false, default: false
  string :source
  string :source_name
  string :comment
  string :table_note
end

DB.create_table! :executive_orders do
  integer :id, primary_key: true
  string :title, null: false
  string :date, null: false
  string :link, null: false
  string :summary, null: false
  string :linkified_summary
  boolean :all_agencies, null: false, default: false
  boolean :directs_doge, null: false, default: false
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

DB.create_table! :agencies_executive_orders do
  foreign_key :agency_id, :agencies, null: false, type: :string
  foreign_key :executive_order_id, :executive_orders, null: false
  unique %i[agency_id executive_order_id]
end

DB.create_table! :documents_positions do
  foreign_key :document_id, :documents, null: false, type: :string
  foreign_key :position_id, :positions, null: false, type: :string
  unique %i[document_id position_id]
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
