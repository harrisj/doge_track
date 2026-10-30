# frozen_string_literal: true

require 'minitest_helper'
require_relative 'support/data_scripts'

class TestValidateSourcesYaml < Minitest::Test
  def setup
    DataScripts.reset_sandbox!
  end

  def teardown
    FileUtils.rm_rf(DataScripts.sandbox)
  end

  def test_accepts_source_with_resolved_publisher
    DataScripts.write_raw('publishers.yaml', <<~YAML)
      - id: pub-1
        name: Sandbox Pub
        short_name: SP
        slug: sandbox-pub
        hostname: sandbox.example.com
    YAML
    DataScripts.write_raw('sources.yaml', <<~YAML)
      - url: https://sandbox.example.com/article
        pub_id: pub-1
        title: Sandbox Article
        pub_date: 2025-01-20
    YAML

    result = DataScripts.run_script(DataScripts.copy_script('validate_sources_yaml.rb'))

    assert_equal 0, result[:status].exitstatus, result[:err]
  end

  def test_rejects_source_with_unknown_publisher
    DataScripts.write_raw('publishers.yaml', <<~YAML)
      - id: pub-1
        name: Sandbox Pub
        short_name: SP
        slug: sandbox-pub
        hostname: sandbox.example.com
    YAML
    DataScripts.write_raw('sources.yaml', <<~YAML)
      - url: https://unknown.example.com/article
        title: Orphan Source
    YAML

    result = DataScripts.run_script(DataScripts.copy_script('validate_sources_yaml.rb'))

    refute_equal 0, result[:status].exitstatus
    assert_includes result[:err], "Couldn't find publisher for host unknown.example.com"
  end
end
