# frozen_string_literal: true

ENV['MT_NO_EXPECTATIONS'] = 'true'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/sequel'
Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new]

require 'bridgetown/test'
