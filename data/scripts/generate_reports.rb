# frozen_string_literal: true
require 'date'
require 'yaml'
require 'fileutils'
require_relative 'models'
require 'edtf-humanize'

REPORTS_DIR = File.join(File.dirname(__FILE__), '..', '..', 'reports')

def generate_people_md
  report_file = File.join(REPORTS_DIR, "people.md")
  open(report_file, "w") do |file|
    Person.eager(positions: :agency, system_roles: {govt_system: :agency}).each do |person|
      file.puts("# #{person.name}\n")
      file.puts("- category: #{person.category}")

      if person.positions.size > 0
        file.puts("- positions:")
        person.positions.each do |pos|
          agency_str = "**#{pos.agency_id}**"

          if pos.start_date || pos.end_date
            if pos.end_date
              end_date = pos.end_date
            elsif pos.nte_date
              end_date = "NTE #{pos.nte_date}"
            else
              end_date = "??"
            end

            date_range = "(#{pos.start_date} to #{end_date})"
          else
            date_range = "dates unknown"
          end

          alias_str = "[as \"#{pos.doge_alias_id}\"]" if pos.doge_alias_id
          title_str = pos.title || ""
          title_str += " #{pos.pay_grade}" if pos.pay_grade
          if pos.supervisory and pos.title
            title_str = "**#{pos.title}**"
          end

          if pos.salary
            salary ||= "volunteer" if pos.salary == "$0"
            salary ||= "#{pos.salary}"
          end

          pos_string = "    -  #{[agency_str, date_range, alias_str, title_str, salary].reject(&:nil?).join(' ')}"
          file.puts pos_string

          # Put in system access
          system_roles = person.system_roles
          agency_system_roles = system_roles.select {|r| r.agency == pos.agency || r.govt_system.agency == pos.agency }
          agency_system_roles.each do |sr|
            sys_name = sr.govt_system.name
            sys_access = " **[#{sr.type} access]**" if sr.type && sr.type != 'read' && sr.type != 'unknown'

            end_date = sr.date_revoked
            end_date ||= "NTE #{sr.date_nte}" if sr.date_nte
            end_date ||= "ongoing"

            sys_date = "#{sr.date_granted} - #{end_date}"
            file.puts "        - #{sys_name}#{sys_access}: #{sys_date}"
          end
        end
      end

      file.puts
    end
  end
end

def generate_agency_md
  report_file = File.join(REPORTS_DIR, "agencies.md")

  open(report_file, 'w') do |file|
    Agency.all.each do |agency|
      file.puts("# #{agency.name}")

      file.puts("- slug: #{agency.slug}")

      if agency.positions.size > 0
        file.puts("- people:")

        agency.positions.sort_by {|r| r.start_date ? r.start_date : '2025-01-20'}.each do |pos|
          if pos.doge_alias
            name = pos.name ? "**#{pos.doge_alias_id} (#{pos.name})**" : "**#{pos.doge_alias_id}**"
          else
            name = "**#{pos.name}**"
          end

          if pos.start_date || pos.end_date || pos.nte_date

            end_date = pos.end_date
            end_date ||= "NTE #{pos.nte_date}" if pos.nte_date && Date.edtf(pos.nte_date) < Date.today

            if end_date
              dates = "(#{pos.start_date} - #{end_date})"
            else
              dates = "(#{pos.start_date})"
            end
          end

          if pos.detail?
            detail = pos.from_agency_id ? "(detailed from #{pos.from_agency_id})" : "(detail)"
          end

          file.puts("  - #{[name, dates, pos.title, detail].reject(&:nil?).join(" ")}")
        end
      end

      systems = {}
      agency.system_roles.each do |sr|
        systems[sr.govt_system_id] ||= []
        systems[sr.govt_system_id].append(sr)
      end

      if systems.size > 0
        file.puts "- systems:"

        systems.each do |system_id, roles|
          system = roles[0].govt_system
          if system.acronym
            file.puts "    - #{system.acronym}: #{system.name}"
          else
            file.puts "    - #{system.name}"
          end
          
          roles.each do |sr|
            if sr.doge_alias
              name = sr.name ? "{sr.doge_alias_id} (#{sr.name})" : "#{sr.doge_alias_id}"
            else
              name = "#{sr.name}"
            end

            sys_access = "**[#{sr.type} access]**" if sr.type && sr.type != 'read' && sr.type != 'unknown'
            
            end_date = sr.date_revoked
            end_date ||= "NTE #{sr.date_nte}" if sr.date_nte
            end_date ||= "ongoing"

            sys_date = "#{sr.date_granted} - #{end_date}"

            file.puts "        - #{[name, sys_access, sys_date].reject(&:nil?).join(' ')}"
          end
        end
      end

      file.puts
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  generate_people_md
  generate_agency_md
end
