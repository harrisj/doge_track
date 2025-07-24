# frozen_string_literal: true

require 'csv'
require 'fileutils'
require_relative 'models'

OUTPUT_DIR = File.join(File.dirname(__FILE__), '..', '..', 'src', 'csv')

def generate_people_csv
  people = Person.eager(:positions).order_by('sort_name').all

  CSV.open(File.join(OUTPUT_DIR, 'people.csv'), 'w') do |csv|
    csv << %w[name sort_name slug age start_date sort_date start_agency agencies skill category
              blurb govt_exit_date govt_exit_truth govt_exit_type linkedin]

    people.each do |person|
      if person.positions.any?
        pos = person.positions.first
        start_date = pos.start_date
        sort_date = pos.sort_date
        start_agency = pos.agency_id
        agencies = person.positions.map(&:agency_id).uniq.join(',')
      else
        sort_date = '2025-01-20'
      end

      csv << [
        person.name,
        person.sort_name,
        person.slug,
        person.age,
        start_date,
        sort_date,
        start_agency,
        agencies,
        person.skill,
        person.category,
        person.blurb,
        person.govt_exit_date,
        person.govt_exit_truth,
        person.govt_exit_type,
        person.linkedin
      ]
    end
  end
end

def generate_positions_csv
  positions = Position.eager(:person, :agency).order_by('id').all

  CSV.open(File.join(OUTPUT_DIR, 'positions.csv'), 'w') do |csv|
    csv << %w[id type agency agency_parent name doge_alias_id from_agency_id from_truth start_date start_date_truth
              start_source start_source_name end_date end_date_truth end_source end_source_name end_type sort_date
              nte_date nte_date_truth signed_date appt_type_code appt_type pay_grade salary pd_code sge excepted title
              title_type series supervisory office source source_name reimbursed reimbursement_amount comment
              qualifications table_note replaced_by same_as person_govt_exit_date person_govt_exit_truth
              person_govt_exit_type]

    positions.each do |pos|
      csv << [
        pos.id,
        pos.type,
        pos.agency_id,
        pos.agency.parent_id,
        pos.name,
        pos.doge_alias_id,
        pos.from_agency_id,
        pos.from_truth,
        pos.start_date,
        pos.start_date_truth,
        pos.start_source,
        pos.start_source_name,
        pos.end_date,
        pos.end_date_truth,
        pos.end_source,
        pos.end_source_name,
        pos.end_type,
        pos.sort_date,
        pos.nte_date,
        pos.nte_date_truth,
        pos.signed_date,
        pos.appt_type_code,
        pos.appt_type,
        pos.pay_grade,
        pos.salary,
        pos.pd_code,
        pos.sge,
        pos.excepted,
        pos.title,
        pos.title_type,
        pos.series,
        pos.supervisory,
        pos.office,
        pos.source,
        pos.source_name,
        pos.reimbursed,
        pos.reimbursement_amount,
        pos.comment,
        pos.qualifications,
        pos.table_note,
        pos.replaced_by,
        pos.same_as,
        pos.person ? pos.person.govt_exit_date : nil,
        pos.person ? pos.person.govt_exit_truth : nil,
        pos.person ? pos.person.govt_exit_type : nil
      ]
    end
  end
end

def generate_events_csv
  events = Event.eager(:people, :doge_aliases, :agencies).order_by(:sort_date).all

  CSV.open(File.join(OUTPUT_DIR, 'events.csv'), 'w') do |csv|
    csv << %w[date sort_date type id text fuzz comment source source_name case_no names aliases agencies]

    events.each do |event|
      csv << [
        event.date,
        event.sort_date,
        event.type,
        event.id,
        event.text,
        event.fuzz,
        event.comment,
        event.source,
        event.source_name,
        event.case_no,
        event.people.map(&:name).uniq.join(', '),
        event.doge_aliases.map(&:id).join(', '),
        event.agencies.map(&:id).join(', ')
      ]
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  generate_people_csv
  generate_positions_csv
  generate_events_csv
end
