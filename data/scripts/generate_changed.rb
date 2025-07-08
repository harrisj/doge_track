# frozen_string_literal: true

require 'yaml'
require 'date'

# git log -p --since="2025-06-10" --until="2025-06-12" ./data/raw_data/people.yaml | grep 'id:'
# git log -p --since="2025-06-10" --until="2025-06-12" ./data/raw_data/agencies.yaml | grep 'id:'

def load_change_log(changes)
  change_log_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'change_log.yaml')
  change_log = YAML.unsafe_load_file(change_log_file, symbolize_names: true)
  changes.each do |rec|
    log_rec = change_log.find { |x| x[:week] == rec[:start] }
    rec[:notes] = log_rec[:notes] if log_rec
  end
end

def count_changed(changes)
  changes.each do |rec|
    rec[:added] = 0
    rec[:deleted] = 0

    log_output = `git diff --numstat '@{#{rec[:start].iso8601} 00:00}..@{#{rec[:end].iso8601} 23:59}'`

    log_output.each_line do |l|
      next unless (match = l.match(/^(\d+)\s+(\d+)\s+([^\s]+)$/))

      added, deleted, path = match.captures

      next unless (path =~ %r{src/} && path !~ %r{_data/}) || path =~ %r{data/}

      rec[:added] += added.to_i
      rec[:deleted] += deleted.to_i
    end
  end
end

def diff_people(changes)
  changes.each do |rec|
    # puts "git diff '@{#{rec[:start].iso8601} 00:00}..@{#{rec[:end].iso8601} 23:59}' -- ./data/raw_data/people.yaml"

    log_output = `git diff '@{#{rec[:start].iso8601} 00:00}..@{#{rec[:end].iso8601} 23:59}' -- ./data/raw_data/people.yaml`
    rec[:positions] = []
    rec[:names] = []
    log_output.each_line do |l|
      if l =~ /^\+\s+- id: /
        id = l.gsub(/^\+\s+- id: /, '').strip
        rec[:positions].append(id)
      elsif l =~ /^\+- name: /
        name = l.gsub(/^\+- name: /, '').strip
        rec[:names].append(name)
      end
    end

    rec[:positions].uniq!
    rec[:names].uniq!
  end
end

def diff_events(changes)
  changes.each do |rec|
    rec[:agencies] = []
    rec[:events] = []

    ['agencies.yaml', 'interagency.yaml'].each do |file|
      log_output = `git diff '@{#{rec[:start].iso8601} 00:00}..@{#{rec[:end].iso8601} 23:59}' -- ./data/raw_data/#{file}`
      log_output.each_line do |l|
        next unless l =~ /^\+\s+id: /

        id = l.gsub(/^\+\s+id: /, '').strip

        if id.size == 8
          rec[:events].append(id)
        else
          rec[:agencies].append(id)
        end
      end
    end

    rec[:agencies].uniq!
    rec[:events].uniq!
  end
end

changes = []
start_of_week = Date.today - Date.today.wday
end_of_week = start_of_week + 6

while start_of_week > Date.parse('2025-05-10')
  changes.append({ start: start_of_week, end: end_of_week })
  start_of_week -= 7
  end_of_week -= 7
end

load_change_log(changes)
count_changed(changes)
diff_people(changes)
diff_events(changes)

changes_file = File.join(File.dirname(__FILE__), '..', '..', 'src', '_data', 'changes.yml')
File.open(changes_file, 'w') do |file|
  out_yaml = YAML.dump(changes, line_width: 150, stringify_names: true, header: false)
  file.write(out_yaml)
end
