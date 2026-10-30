# frozen_string_literal: true

require 'minitest_helper'
require_relative 'support/data_scripts'

class TestValidateDb < Minitest::Test
  def setup
    DataScripts.reset_sandbox!
  end

  def teardown
    FileUtils.rm_rf(DataScripts.sandbox)
  end

  def test_position_validation_helpers_load_and_run
    script = DataScripts.copy_script('validate_db.rb')

    result = DataScripts.run_script(script)

    assert_equal 0, result[:status].exitstatus, result[:err]

    result = DataScripts.run_ruby('-e', "load #{script.inspect}; validate_no_events_before_position_start")

    assert_equal 0, result[:status].exitstatus, result[:err]
  end
end
