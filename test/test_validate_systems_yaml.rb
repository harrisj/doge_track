# frozen_string_literal: true

require 'minitest_helper'
require_relative 'support/data_scripts'

class TestValidateSystemsYaml < Minitest::Test
  def setup
    DataScripts.reset_sandbox!
  end

  def teardown
    FileUtils.rm_rf(DataScripts.sandbox)
  end

  def test_accepts_system_with_access
    DataScripts.write_raw('systems.yaml', <<~YAML)
      ---
      - name: Acquisition Performance and Execution
        acronym: APEX
        id: apex
        type: internal
        agency: CDC
        access:
        - id: apex-access
          type: read
          name: Luke Farritor
          date_granted: 2025-02-04
    YAML

    result = DataScripts.run_script(DataScripts.copy_script('validate_systems_yaml.rb'))

    assert_equal 0, result[:status].exitstatus, result[:err]
  end

  def test_rejects_access_missing_name_or_alias
    DataScripts.write_raw('systems.yaml', <<~YAML)
      ---
      - name: Acquisition Performance and Execution
        acronym: APEX
        id: apex
        type: internal
        agency: CDC
        access:
        - id: apex-access
          type: read
    YAML

    result = DataScripts.run_script(DataScripts.copy_script('validate_systems_yaml.rb'))

    refute_equal 0, result[:status].exitstatus
    assert_includes result[:err], 'Must have name or alias for'
  end
end
