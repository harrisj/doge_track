# frozen_string_literal: true

require 'sequel'

DB_PATH = File.join(File.dirname(__FILE__), '..', 'doge.sqlite')
DB = Sequel.sqlite(DB_PATH)

require 'require_all'
require_all File.join(File.dirname(__FILE__), '..', '..', 'models')
