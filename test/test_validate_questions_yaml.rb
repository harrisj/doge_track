# frozen_string_literal: true

require 'minitest_helper'
require_relative 'support/data_scripts'

class TestValidateQuestionsYaml < Minitest::Test
  def setup
    DataScripts.reset_sandbox!
  end

  def teardown
    FileUtils.rm_rf(DataScripts.sandbox)
  end

  def test_assigns_missing_ids_and_accepts_valid_questions
    DataScripts.write_raw('questions.yaml', <<~YAML)
      ---
      - name: Test Person
        question: What happened to Test Person?
    YAML

    result = DataScripts.run_script(DataScripts.copy_script('validate_questions_yaml.rb'))

    assert_equal 0, result[:status].exitstatus, result[:err]

    questions = YAML.unsafe_load(File.read(DataScripts.sandbox_data_path('questions.yaml')), symbolize_names: true)

    assert_equal 1, questions.length
    assert questions.first.key?(:id)
  end
end
