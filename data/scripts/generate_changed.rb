# frozen_string_literal: true

require 'yaml'
require 'date'

LOOKBACK_WEEKS = 1

SPLIT_START = Date.parse('2026-10-25')
SPLIT_BASE = 'afe019892e9b45dc5d2b9243bf7fc058b42fd45f'

CHANGES_FILE = File.join(File.dirname(__FILE__), '..', '..', 'src', '_data', 'changes.yml')

# git log -p --since="2025-06-10" --until="2025-06-12" ./data/raw_data/people.yaml | grep 'id:'
# git log -p --since="2025-06-10" --until="2025-06-12" ./data/raw_data/agencies.yaml | grep 'id:'

# Diffs from the start of the week, or from the post-split tree when the
# week contains the file split. Diffing against the pre-split tree makes the
# mechanical move of whole files into per-agency directories read as a full
# rewrite, so every agency/event/person shows up as new.
def week_diff_base(key)
  end_date = key + 6
  return SPLIT_BASE if SPLIT_START.between?(key, end_date)

  "@{#{key.iso8601} 00:00}"
end

def load_changes(week_changes)
  changes = YAML.unsafe_load_file(CHANGES_FILE, symbolize_names: true)
  changes.each do |rec|
    week_changes[rec[:start]] = rec
  end
end

def load_change_log(week_changes)
  change_log_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'change_log.yaml')
  change_log = YAML.unsafe_load_file(change_log_file, symbolize_names: true)
  change_log.each do |rec|
    raise "Fix #{rec[:week]} to be a Sunday" unless rec[:week].wday.zero?

    week_changes[rec[:week]] ||= { start: rec[:week], end: rec[:week] + 6 }
    week_changes[rec[:week]][:notes] = rec[:notes]
  end
end

def load_missing_weeks(week_changes)
  start_of_week = Date.today - Date.today.wday

  (0..LOOKBACK_WEEKS).each do |wk|
    key = start_of_week - (7 * wk)
    week_changes[key] ||= { start: key, end: key + 6 }
  end
end

def count_changed(week_changes)
  week_changes.keys.sort.reverse.first(LOOKBACK_WEEKS).each do |key|
    rec = week_changes[key]
    rec[:added] = 0
    rec[:deleted] = 0

    # puts "git diff --numstat '@{#{rec[:start].iso8601} 00:00}..@{#{rec[:end].iso8601} 23:59}'"
    log_output = `git diff --numstat '#{week_diff_base(rec[:start])}..@{#{rec[:end].iso8601} 23:59}'`
    log_output.each_line do |l|
      next unless (match = l.match(/^(\d+)\s+(\d+)\s+([^\s]+)$/))

      added, deleted, path = match.captures

      next unless (path =~ %r{src/} && path !~ %r{_data/}) || path =~ %r{data/}

      rec[:added] += added.to_i
      rec[:deleted] += deleted.to_i
    end
  end
end

def diff_people(week_changes)
  week_changes.keys.sort.reverse.first(LOOKBACK_WEEKS).each do |key|
    rec = week_changes[key]
    # puts "git diff '@{#{rec[:start].iso8601} 00:00}..@{#{rec[:end].iso8601} 23:59}' -- ./data/raw_data/people.yaml"

    use_dir = rec[:start] >= SPLIT_START
    log_output = if use_dir
                   `git diff '#{week_diff_base(rec[:start])}..@{#{rec[:end].iso8601} 23:59}' -- ./data/raw_data/people/`
                 else
                   `git diff '#{week_diff_base(rec[:start])}..@{#{rec[:end].iso8601} 23:59}' -- ./data/raw_data/people.yaml`
                 end
    rec[:positions] = []
    rec[:names] = []
    log_output.each_line do |l|
      if l =~ /^\+\s*- id: /
        id = l.sub(/^\+\s*- id: /, '').strip
        rec[:positions].append(id)
      elsif l =~ /^\+\s*-?\s*name: /
        name = l.sub(/^\+\s*-?\s*name: /, '').strip
        rec[:names].append(name)
      end
    end

    rec[:positions].uniq!
    rec[:names].uniq!
  end
end

def diff_events(week_changes)
  week_changes.keys.sort.reverse.first(LOOKBACK_WEEKS).each do |key|
    rec = week_changes[key]
    rec[:agencies] = []
    rec[:events] = []

    use_dir = rec[:start] >= SPLIT_START
    files = if use_dir
              ['./data/raw_data/agencies/', './data/raw_data/interagency.yaml']
            else
              ['agencies.yaml', 'interagency.yaml']
            end
    files.each do |spec|
      log_output = if use_dir
                     `git diff '#{week_diff_base(rec[:start])}..@{#{rec[:end].iso8601} 23:59}' -- #{spec}`
                   else
                     `git diff '#{week_diff_base(rec[:start])}..@{#{rec[:end].iso8601} 23:59}' -- ./data/raw_data/#{spec}`
                   end
      log_output.each_line do |l|
        next unless l =~ /^\+\s*-?\s*id: /

        id = l.sub(/^\+\s*-?\s*id: /, '').strip

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

week_changes = {}
load_changes(week_changes)
load_change_log(week_changes)
load_missing_weeks(week_changes)

count_changed(week_changes)
diff_people(week_changes)
diff_events(week_changes)

out_changes = week_changes.keys.sort.reverse.map { |k| week_changes[k] }

File.open(CHANGES_FILE, 'w') do |file|
  out_yaml = YAML.dump(out_changes, line_width: 150, stringify_names: true, header: false)
  file.write(out_yaml)
end
