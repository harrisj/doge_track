# frozen_string_literal: true

require 'minitest_helper'
require_relative 'support/data_scripts'

class TestValidatePeopleYaml < Minitest::Test
  def setup
    DataScripts.reset_sandbox!
  end

  def teardown
    FileUtils.rm_rf(DataScripts.sandbox)
  end

  def write_person(person_yaml)
    DataScripts.write_raw('people/test-person.yaml', <<~YAML)
      ---
      #{person_yaml}
    YAML
  end

  def test_rejects_person_without_name
    write_person(<<~YAML)
      sort_name: Person, Test
      slug: test-person
      positions:
      - id: pos-dhs-1
        type: appointed
        agency: DHS
        category: builder
        title: Test Title
        start_date: 2025-01-20
    YAML

    result = DataScripts.run_script(DataScripts.copy_script('validate_people_yaml.rb'))

    refute_equal 0, result[:status].exitstatus
    assert_includes result[:err], 'No name for'
  end

  def test_rejects_person_with_unparseable_start_date
    write_person(<<~YAML)
      name: Test Person
      sort_name: Person, Test
      slug: test-person
      positions:
      - id: pos-dhs-1
        type: appointed
        agency: DHS
        category: builder
        title: Test Title
        start_date: 2025-99-99
    YAML

    result = DataScripts.run_script(DataScripts.copy_script('validate_people_yaml.rb'))

    refute_equal 0, result[:status].exitstatus
    assert_includes result[:err], "Can't parse EDTF date 2025-99-99"
  end

  def test_accepts_valid_person
    write_person(<<~YAML)
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
    YAML

    result = DataScripts.run_script(DataScripts.copy_script('validate_people_yaml.rb'))

    assert_equal 0, result[:status].exitstatus, result[:err]
  end
end
