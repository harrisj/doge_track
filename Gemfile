# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

####
# Welcome to your project's Gemfile, used by Rubygems & Bundler.
#
# To install a plugin, run:
#
#   bundle add new-plugin-name -g bridgetown_plugins
#
# This will ensure the plugin is added to the correct Bundler group.
#
# When you run Bridgetown commands, we recommend using a binstub like so:
#
#   bin/bridgetown start (or console, etc.)
#
# This will help ensure the proper Bridgetown version is running.
####

# If you need to upgrade/switch Bridgetown versions, change the line below
# and then run `bundle update bridgetown`
gem 'bridgetown', '~> 2.2.0'

# Uncomment to add file-based dynamic routing to your project:
# gem "bridgetown-routes", "~> 1.3.4"

# Puma is the Rack-compatible web server used by Bridgetown
# (you can optionally limit this to the "development" group)
gem 'puma', '< 7'

# Uncomment to use the Inspectors API to manipulate the output
# of your HTML or XML resources:
# gem "nokogiri", "~> 1.13"

# Or for faster parsing of HTML-only resources via Inspectors, use Nokolexbor:
gem 'nokolexbor', '~> 0.4'

gem 'bridgetown-quick-search', '~> 3.0'
gem 'bridgetown-seo-tag', '~> 7.0'
gem 'bridgetown_sequel', '~> 1.1'
gem 'bridgetown-sitemap', '~> 3.0'
gem 'edtf', '~> 3.2'
gem 'edtf-humanize', '~> 2.3'
gem 'kramdown'
gem 'nokogiri', '~> 1.18'
gem 'racc', '~> 1.8'
gem 'require_all', '~> 3.0'
gem 'sanitize', '~> 7.0'
gem 'sequel', '~> 5.92'
gem 'shortuuid', '~> 0.6.0'
gem 'sqlite3', '~> 2.6'

group :test do
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'minitest-sequel', '~> 0.3.2'
  gem 'rack-test'
  gem 'rubocop-bridgetown'
end

group :development do
  gem 'rubocop', '~> 1.75'
  gem 'rubocop-minitest', '~> 0.39.1'
  gem 'rubocop-sequel', '~> 0.4.1'
end
