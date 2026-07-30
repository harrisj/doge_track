# frozen_string_literal: true

require 'yaml'
require 'date'

LOOKBACK_WEEKS = 12

WEEK_CHANGES = {}.freeze
CHANGES_FILE = File.join(File.dirname(__FILE__), '..', '..', 'src', '_data', 'changes.yml')

# git log -p --since="2025-06-10" --until="2025-06-12" ./data/raw_data/people.yaml | grep 'id:'
# git log -p --since="2025-06-10" --until="2025-06-12" ./data/raw_data/agencies.yaml | grep 'id:'

def load_changes
  changes = YAML.unsafe_load_file(CHANGES_FILE, symbolize_names: true)
  changes.each do |rec|
    WEEK_CHANGES[rec[:start]] = rec
  end
end

def load_change_log
  change_log_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'change_log.yaml')
  change_log = YAML.unsafe_load_file(change_log_file, symbolize_names: true)
  change_log.each do |rec|
    raise "Fix #{rec[:week]} to be a Sunday" unless rec[:week].wday.zero?

    WEEK_CHANGES[rec[:week]] ||= { start: rec[:week], end: rec[:week] + 6 }
    WEEK_CHANGES[rec[:week]][:notes] = rec[:notes]
  end
end

def load_missing_weeks
  start_of_week = Date.today - Date.today.wday

  (0..LOOKBACK_WEEKS).each do |wk|
    key = start_of_week - (7 * wk)
    WEEK_CHANGES[key] ||= { start: key, end: key + 6 }
  end
end

def count_changed
  WEEK_CHANGES.keys.sort.reverse.first(LOOKBACK_WEEKS).each do |key|
    rec = WEEK_CHANGES[key]
    rec[:added] = 0
    rec[:deleted] = 0

    # puts "git diff --numstat '@{#{rec[:start].iso8601} 00:00}..@{#{rec[:end].iso8601} 23:59}'"
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

def diff_people
  WEEK_CHANGES.keys.sort.reverse.first(LOOKBACK_WEEKS).each do |key|
    rec = WEEK_CHANGES[key]
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

def diff_events
  WEEK_CHANGES.keys.sort.reverse.first(LOOKBACK_WEEKS).each do |key|
    rec = WEEK_CHANGES[key]
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

load_changes
load_change_log
load_missing_weeks

count_changed
diff_people
diff_events

out_changes = WEEK_CHANGES.keys.sort.reverse.map { |k| WEEK_CHANGES[k] }

File.open(CHANGES_FILE, 'w') do |file|
  out_yaml = YAML.dump(out_changes, line_width: 150, stringify_names: true, header: false)
  file.write(out_yaml)
end
