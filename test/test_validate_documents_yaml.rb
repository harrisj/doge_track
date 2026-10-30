# frozen_string_literal: true

require 'minitest_helper'
require_relative 'support/data_scripts'

class TestValidateDocumentsYaml < Minitest::Test
  def setup
    DataScripts.reset_sandbox!
  end

  def teardown
    FileUtils.rm_rf(DataScripts.sandbox)
  end

  def test_rejects_duplicate_document_ids
    script = DataScripts.copy_script('validate_documents_yaml.rb')
    DataScripts.write_raw('documents.yaml', <<~YAML)
      ---
      - id: doc-1
        type: onboard
      - id: doc-1
        type: onboard
    YAML

    result = DataScripts.run_script(script)

    refute_equal 0, result[:status].exitstatus
    assert_includes result[:err], 'Duplicate IDs for documents'
  end

  def test_accepts_unique_document_ids
    script = DataScripts.copy_script('validate_documents_yaml.rb')
    DataScripts.write_raw('documents.yaml', <<~YAML)
      ---
      - id: doc-1
        type: onboard
      - id: doc-2
        type: directory
    YAML

    result = DataScripts.run_script(script)

    assert_equal 0, result[:status].exitstatus, result[:err]
  end
end
