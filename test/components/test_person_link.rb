# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../minitest_helper'

class TestPersonLink < Minitest::Test
  def test_person_link_person
    person = Person.with_pk!('Luke Farritor')
    rendered = Bridgetown::TemplateView.render(Atoms::PersonLink.new(person: person))

    assert_equal '<a class="link-hover" href="/names/luke-farritor">Luke Farritor</a>', rendered.call
  end

  def test_person_link_display; end

  def test_person_link_name; end
end
