# frozen_string_literal: true

require 'minitest_helper'
require_relative 'support/data_scripts'

class TestValidateAliasesYaml < Minitest::Test
  def setup
    DataScripts.reset_sandbox!
  end

  def teardown
    FileUtils.rm_rf(DataScripts.sandbox)
  end

  def test_rejects_alias_missing_id
    DataScripts.write_raw('aliases/dhs-01.yaml', <<~YAML)
      agency: DHS
      name: Test Person
    YAML

    result = DataScripts.run_script(DataScripts.copy_script('validate_aliases_yaml.rb'))

    refute_equal 0, result[:status].exitstatus
    assert_includes result[:err], 'No ID found for'
  end

  def test_rejects_multiple_mappings_for_same_agency_name
    DataScripts.write_raw('aliases/dhs-01.yaml', <<~YAML)
      id: DHS-01
      agency: DHS
      name: Test Person
    YAML
    DataScripts.write_raw('aliases/dhs-02.yaml', <<~YAML)
      id: DHS-02
      agency: DHS
      name: Test Person
    YAML

    result = DataScripts.run_script(DataScripts.copy_script('validate_aliases_yaml.rb'))

    refute_equal 0, result[:status].exitstatus
    assert_includes result[:err], 'Multiple mappings at same agency'
  end

  def test_accepts_single_alias_mapping
    DataScripts.write_raw('aliases/dhs-01.yaml', <<~YAML)
      id: DHS-01
      agency: DHS
      name: Test Person
      source: https://sandbox.example.com/article
    YAML

    result = DataScripts.run_script(DataScripts.copy_script('validate_aliases_yaml.rb'))

    assert_equal 0, result[:status].exitstatus, result[:err]
  end
end
