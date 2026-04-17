# frozen_string_literal: true

require_relative '../minitest_helper'

class TestPersonLink < Bridgetown::Test
  # def test_person_link_person
  #   person = ::Person.with_pk!('Luke Farritor')
  #   rendered = Bridgetown::TemplateView.render(::Atoms::PersonLink.new(person: person))

  #   assert_equal '<a class="link-hover" href="/names/luke-farritor">Luke Farritor</a>', rendered.call
  # end

  # def test_person_link_display; end

  # def test_person_link_name
  #   person = ::Person.with_pk!('Luke Farritor')
  #   rendered = Bridgetown::TemplateView.render(::Atoms::PersonLink.new(name: person.name))

  #   assert_equal '<a class="link-hover" href="/names/luke-farritor">Luke Farritor</a>', rendered.call
  # end

  # def test_person_link_name_no_raise
  #   name = "Bob Fakename"
  #   rendered = Bridgetown::TemplateView.render(::Atoms::PersonLink.new(name: name))

  #   assert_equal name, rendered.call
  # end

  # def test_person_link_no_name_or_person
  #   assert_raises do
  #     ::Atoms::PersonLink.new()
  #   end
  # end

  # def test_person_link_no_args_no_raise
  #   template = ::Atoms::PersonLink.new(raise_miss: false)
  #   rendered = Bridgetown::TemplateView.render(::Atoms::PersonLink.new(person: person))

  #   assert_equal '', rendered
  # end
end
