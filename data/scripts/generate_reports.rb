# frozen_string_literal: true

require 'date'
require 'yaml'
require 'fileutils'
require_relative 'models'
require 'edtf-humanize'

REPORTS_DIR = File.join(File.dirname(__FILE__), '..', '..', 'reports')

def generate_people_md
  report_file = File.join(REPORTS_DIR, 'people.md')
  File.open(report_file, 'w') do |file|
    Person.eager(positions: :agency, system_roles: { govt_system: :agency }).each do |person|
      file.puts("# #{person.name}\n")
      file.puts("- category: #{person.category}")

      if person.positions.size.positive?
        file.puts('- positions:')
        person.positions.each do |pos|
          agency_str = "**#{pos.agency_id}**"

          if pos.start_date || pos.end_date
            end_date = if pos.end_date
                         pos.end_date
                       elsif pos.nte_date
                         "NTE #{pos.nte_date}"
                       else
                         '??'
                       end

            date_range = "(#{pos.start_date} to #{end_date})"
          else
            date_range = ''
          end

          alias_str = "[as \"#{pos.doge_alias_id}\"]" if pos.doge_alias_id
          title_str = pos.title || ''
          title_str += " #{pos.pay_grade}" if pos.pay_grade
          title_str = "**#{pos.title}**" if pos.supervisory && pos.title

          if pos.salary
            salary ||= 'volunteer' if pos.salary == '$0'
            salary ||= pos.salary.to_s
          end

          pos_string = "    -  #{[agency_str, date_range, alias_str, title_str, salary].compact.join(' ')}"
          file.puts pos_string

          # Put in system access
          system_roles = person.system_roles
          agency_system_roles = system_roles.select { |r| r.agency == pos.agency || r.govt_system.agency == pos.agency }
          agency_system_roles.each do |sr|
            sys_name = if sr.govt_system.acronym
                         "#{sr.govt_system.acronym}: #{sr.govt_system.name}"
                       else
                         sr.govt_system.name
                       end
            sys_access = " **[#{sr.type} access]**" if sr.type && sr.type != 'read' && sr.type != 'unknown'

            end_date = sr.date_revoked
            end_date ||= "NTE #{sr.date_nte}" if sr.date_nte
            end_date ||= 'ongoing'

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
  report_file = File.join(REPORTS_DIR, 'agencies.md')

  File.open(report_file, 'w') do |file|
    Agency.all.each do |agency|
      file.puts("# #{agency.name}")

      file.puts("- slug: #{agency.slug}")

      if agency.positions.size.positive?
        file.puts('- people:')

        agency.positions.sort_by { |r| r.start_date || '2025-01-20' }.each do |pos|
          name = if pos.doge_alias
                   pos.name ? "**#{pos.doge_alias_id} (#{pos.name})**" : "**#{pos.doge_alias_id}**"
                 else
                   "**#{pos.name}**"
                 end

          if pos.start_date || pos.end_date || pos.nte_date

            end_date = pos.end_date
            end_date ||= "NTE #{pos.nte_date}" if pos.nte_date && Date.edtf(pos.nte_date) < Date.today

            dates = if end_date
                      "(#{pos.start_date} - #{end_date})"
                    else
                      "(#{pos.start_date})"
                    end
          end

          if pos.detail?
            detail = pos.from_agency_id ? "(detailed from #{pos.from_agency_id})" : '(detail)'
          end

          file.puts("  - #{[name, dates, pos.title, detail].compact.join(' ')}")
        end
      end

      systems = {}
      agency.system_roles.each do |sr|
        systems[sr.govt_system_id] ||= []
        systems[sr.govt_system_id].append(sr)
      end

      if systems.size.positive?
        file.puts '- systems:'

        systems.each_value do |roles|
          system = roles[0].govt_system
          if system.acronym
            file.puts "    - #{system.acronym}: #{system.name}"
          else
            file.puts "    - #{system.name}"
          end

          roles.each do |sr|
            name = if sr.doge_alias
                     sr.name ? "{sr.doge_alias_id} (#{sr.name})" : sr.doge_alias_id.to_s
                   else
                     sr.name.to_s
                   end

            sys_access = "**[#{sr.type} access]**" if sr.type && sr.type != 'read' && sr.type != 'unknown'

            end_date = sr.date_revoked
            end_date ||= "NTE #{sr.date_nte}" if sr.date_nte
            end_date ||= 'ongoing'

            sys_date = "#{sr.date_granted} - #{end_date}"

            file.puts "        - #{[name, sys_access, sys_date].compact.join(' ')}"
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
