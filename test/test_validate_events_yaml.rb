# frozen_string_literal: true

require 'minitest_helper'
require_relative 'support/data_scripts'

class TestValidateEventsYaml < Minitest::Test
  def setup
    DataScripts.reset_sandbox!
  end

  def teardown
    FileUtils.rm_rf(DataScripts.sandbox)
  end

  def test_rejects_event_missing_source
    DataScripts.write_raw('agencies/dhs.yaml', <<~YAML)
      id: DHS
      name: Department of Homeland Security
      slug: dhs
      short_name: DHS
      events:
      - id: ev-dhs-1
        type: sighting
        date: 2025-01-20
        event: DOGE makes first contact
        agency: DHS
    YAML
    DataScripts.write_raw('interagency.yaml', "[]\n")

    result = DataScripts.run_script(DataScripts.copy_script('validate_events_yaml.rb'))

    refute_equal 0, result[:status].exitstatus
    assert_includes result[:err], 'has no source'
  end

  def test_rejects_agency_missing_short_name
    DataScripts.write_raw('agencies/dhs.yaml', <<~YAML)
      id: DHS
      name: Department of Homeland Security
      slug: dhs
      events: []
    YAML
    DataScripts.write_raw('interagency.yaml', "[]\n")

    result = DataScripts.run_script(DataScripts.copy_script('validate_events_yaml.rb'))

    refute_equal 0, result[:status].exitstatus
    assert_includes result[:err], 'Missing short_name for agency'
  end

  def test_accepts_valid_agency_event
    DataScripts.write_raw('agencies/dhs.yaml', <<~YAML)
      id: DHS
      name: Department of Homeland Security
      slug: dhs
      short_name: DHS
      events:
      - id: ev-dhs-1
        type: sighting
        date: 2025-01-20
        event: DOGE makes first contact
        source: https://sandbox.example.com/article
        agency: DHS
    YAML
    DataScripts.write_raw('interagency.yaml', "[]\n")

    result = DataScripts.run_script(DataScripts.copy_script('validate_events_yaml.rb'))

    assert_equal 0, result[:status].exitstatus, result[:err]
  end
end
