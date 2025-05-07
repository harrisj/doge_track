require "bridgetown"

Bridgetown.load_tasks

# Run rake without specifying any command to execute a deploy build by default.
task default: :deploy

#
# Standard set of tasks, which you can customize if you wish:
#
desc "Build the Bridgetown site for deployment"
task :deploy => [:clean, "frontend:build"] do
  Bridgetown::Commands::Build.start
end

desc "Build the site in a test environment"
task :test do
  ENV["BRIDGETOWN_ENV"] = "test"
  Bridgetown::Commands::Build.start
end

desc "Runs the clean command"
task :clean do
  Bridgetown::Commands::Clean.start
end

namespace :frontend do
  desc "Build the frontend with esbuild for deployment"
  task :build do
    sh "yarn run esbuild"
  end

  desc "Watch the frontend with esbuild during development"
  task :dev do
    sh "yarn run esbuild-dev"
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

SCRIPTS_DIR = "data/scripts"

namespace :data do
  desc "Delete the SQLite database"
  task :clean_yaml do
    sh "rm data/doge.sqlite"
  end

  desc "Clean out all the generated YAML data"
  task :clean_yaml do
    sh "rm src/_data/doge/**/*.yaml"
  end

  desc "Delete all the pregenerated API files"
  task :clean_api do
    sh "rm src/api/**/*.json"
  end

  desc "Clean all generated data files"
  task clean: [:clean_db, :clean_yaml, :clean_api]

  desc "Process the events YAML file"
  task :process_events do
    ruby "#{SCRIPTS_DIR}/process_events_yaml.rb"
  end

  desc "Create an empty database for loading data"
  task :create_db do
    ruby "#{SCRIPTS_DIR}/create_db.rb"
  end
  
  desc "Pull in data from the YAML files into the database"
  task :populate_db do
    ruby "#{SCRIPTS_DIR}/populate_db.rb"
  end
  
  desc "Cleans all generated data, recreates the DB and loads it with data"
  task rebuild_db: %w[clean create_db populate_db]
  
  desc "Build files in the _data dir for use by pages"
  task :build_data_yaml do
    ruby "#{SCRIPTS_DIR}/generate_data_yaml.rb"
  end
  
  desc "Builds statically generated API JSON"
  task :build_api_json do
    ruby "#{SCRIPTS_DIR}/generate_api_json.rb"
  end
end