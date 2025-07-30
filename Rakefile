# frozen_string_literal: true

require 'bridgetown'
require 'bridgetown_sequel'
Bridgetown.load_tasks

# Run rake without specifying any command to execute a deploy build by default.
task default: :deploy

#
# Standard set of tasks, which you can customize if you wish:
#
desc 'Build the Bridgetown site for deployment'
task deploy: [:clean, 'frontend:build', 'data:deploy_db'] do
  Bridgetown::Commands::Build.start
end

desc 'Build the site in a test environment'
task :test do
  ENV['BRIDGETOWN_ENV'] = 'test'
  Bridgetown::Commands::Build.start
end

desc 'Runs the clean command'
task :clean do
  Bridgetown::Commands::Clean.start
end

namespace :frontend do
  desc 'Build the frontend with esbuild for deployment'
  task :build do
    sh 'touch frontend/styles/jit-refresh.css' if ENV['BRIDGETOWN_ENV'] == 'production'
    sh 'yarn run esbuild'
  end

  desc 'Watch the frontend with esbuild during development'
  task :dev do
    sh 'yarn run esbuild-dev'
  rescue Interrupt
  end
end

#
# Add your own Rake tasks here! You can use `environment` as a prerequisite
# in order to write automations or other commands requiring a loaded site.
#
# task :my_task => :environment do
#   puts site.root_dir
#   automation do
#     say_status :rake, "I'm a Rake tast =) #{site.config.url}"
#   end
# end

SCRIPTS_DIR = 'data/scripts'

namespace :data do
  desc 'Delete the SQLite database'
  task :clean_db do
    sh 'rm -f data/doge.sqlite'
  end

  desc 'Delete all the pregenerated API files'
  task :clean_api do
    sh 'rm -f src/api/**/*.json'
  end

  desc 'Clean all generated data files'
  task clean: %i[clean_db clean_api]

  desc 'Process and validate the documents YAML file'
  task :validate_documents_yaml do
    ruby "#{SCRIPTS_DIR}/validate_documents_yaml.rb"
  end

  desc 'Process and validate the events YAML file'
  task :validate_events_yaml do
    ruby "#{SCRIPTS_DIR}/validate_events_yaml.rb"
  end

  desc 'Process and validate the events YAML file'
  task :validate_aliases_yaml do
    ruby "#{SCRIPTS_DIR}/validate_aliases_yaml.rb"
  end

  desc 'Process and validate the people YAML file'
  task validate_people_yaml: 'validate_aliases_yaml' do
    ruby "#{SCRIPTS_DIR}/validate_people_yaml.rb"
  end

  desc 'Process and validate the systems YAML file'
  task validate_systems_yaml: 'validate_aliases_yaml' do
    ruby "#{SCRIPTS_DIR}/validate_systems_yaml.rb"
  end

  desc 'Process and validate the questions YAML file'
  task :validate_questions_yaml do
    ruby "#{SCRIPTS_DIR}/validate_questions_yaml.rb"
  end

  desc 'Validate all raw data YAML files'
  task validate: %i[validate_aliases_yaml validate_documents_yaml validate_events_yaml validate_people_yaml
                    validate_systems_yaml validate_questions_yaml]

  desc 'Create an empty database for loading data'
  task :create_db do
    ruby "#{SCRIPTS_DIR}/create_db.rb"
  end

  desc 'Pull in data from the YAML files into the database'
  task :populate_db do
    ruby "#{SCRIPTS_DIR}/populate_db.rb"
    ruby "#{SCRIPTS_DIR}/linkify_db.rb"
  end

  task deploy_db: ['data:clean_db', 'data:create_db', 'data:populate_db']

  desc 'Cleans all generated data, recreates the DB and loads it with data'
  task rebuild_db: ['data:validate', 'data:clean_db', 'data:create_db', 'data:populate_db']
end

namespace :generate do
  desc 'Generate reports in the repo as markdown files'
  task :reports do
    ruby "#{SCRIPTS_DIR}/generate_reports.rb"
  end

  desc 'Generate data files in the _data directory'
  task :data_yaml do
    ruby "#{SCRIPTS_DIR}/generate_data_yaml.rb"
  end

  desc 'Builds statically generated API JSON'
  task :api_data do
    ruby "#{SCRIPTS_DIR}/generate_api_json.rb"
  end

  desc 'The changes file'
  task :changed do
    ruby "#{SCRIPTS_DIR}/generate_changed.rb"
  end

  desc 'The CSV files'
  task :csv do
    ruby "#{SCRIPTS_DIR}/generate_csv_files.rb"
  end

  desc 'Run all generate tasks'
  task all: %i[data_yaml csv]
end

desc 'Run generate tasks for the content'
task generate: 'generate:all'

desc 'Clean and regenerate all the pages'
task regenerate: ['data:rebuild_db', 'generate']

desc 'Record what has changed (slower to run)'
task changed: 'generate:changed'
