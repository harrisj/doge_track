# frozen_string_literal: true

require 'minitest_helper'
require_relative 'support/data_scripts'
require 'sequel'

class TestPopulateDb < Minitest::Test
  def setup
    DataScripts.reset_sandbox!
    @create_db = DataScripts.copy_script('create_db.rb')
    @populate_db = DataScripts.copy_script('populate_db.rb')
    DataScripts.copy_models!
  end

  def teardown
    FileUtils.rm_rf(DataScripts.sandbox)
  end

  def write_fixtures # rubocop:disable Metrics/MethodLength
    DataScripts.write_raw('agencies/dhs.yaml', <<~YAML)
      id: DHS
      name: Department of Homeland Security
      slug: dhs
      short_name: DHS
      doge_base: true
      blurb: Sandbox agency for testing
      events:
      - id: ev-dhs-1
        type: sighting
        date: 2025-01-20
        sort_date: 2025-01-20
        text: DOGE makes first contact with DHS
        source: https://sandbox.example.com/article
        agency: DHS
    YAML
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
    DataScripts.write_raw('projects.yaml', <<~YAML)
      - id: sandbox-project
        title: Sandbox Project
        summary: Sandbox project summary
        path: /sandbox
        label_text: Sandbox
        label_color: "#000000"
    YAML
    DataScripts.write_raw('entities.yaml', <<~YAML)
      - id: sandbox-entity
        title: Sandbox Entity
        description: A sandbox entity
        type: business
        website: https://example.com
        visible: true
    YAML
    DataScripts.write_raw('people/test-person.yaml', <<~YAML)
      name: Test Person
      sort_name: Person, Test
      slug: test-person
      positions:
      - id: pos-dhs-1
        type: appointed
        agency: DHS
        category: builder
        title: Test Title
        start_date: 2025-01-20
        source: https://sandbox.example.com/article
        project: sandbox-project
    YAML
    DataScripts.write_raw('aliases/test-alias.yaml', <<~YAML)
      id: DHS-01
      agency: DHS
      name: Test Person
      source: https://sandbox.example.com/article
    YAML
    DataScripts.write_raw('cases.yaml', "[]\n")
    DataScripts.write_raw('questions.yaml', "[]\n")
    DataScripts.write_raw('exec_orders.yaml', "[]\n")
    DataScripts.write_raw('systems.yaml', "[]\n")
    DataScripts.write_raw('interagency.yaml', "[]\n")
  end

  def test_populates_database_from_valid_fixtures
    write_fixtures

    create_result = DataScripts.run_script(@create_db)

    assert_equal 0, create_result[:status].exitstatus, create_result[:err]

    populate_result = DataScripts.run_script(@populate_db)

    assert_equal 0, populate_result[:status].exitstatus, populate_result[:err]

    db = Sequel.sqlite(DataScripts.sandbox_db)

    assert_equal 1, db[:agencies].count
    assert_equal 1, db[:people].count
    assert_equal 1, db[:positions].count
    assert_equal 1, db[:events].count
    assert_equal 1, db[:sources].count
    assert_equal 1, db[:projects].count
    assert_equal 1, db[:entities].count
  end

  def test_populate_rejects_event_without_id
    write_fixtures

    DataScripts.write_raw('agencies/dhs.yaml', <<~YAML)
      id: DHS
      name: Department of Homeland Security
      slug: dhs
      short_name: DHS
      events:
      - type: sighting
        date: 2025-01-20
        sort_date: 2025-01-20
        text: DOGE makes first contact with DHS
        source: https://sandbox.example.com/article
        agency: DHS
    YAML

    create_result = DataScripts.run_script(@create_db)

    assert_equal 0, create_result[:status].exitstatus, create_result[:err]

    populate_result = DataScripts.run_script(@populate_db)

    refute_equal 0, populate_result[:status].exitstatus
    assert_includes populate_result[:err], 'Event is missing a unique ID'
  end
end
