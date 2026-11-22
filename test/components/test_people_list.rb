# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/compact_list'
require_relative '../../src/_components/atoms/people_list'

class TestPeopleList < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  it 'links each person in the list' do
    people = ::Person.limit(2).all
    rendered = Bridgetown::TemplateView.render(::Atoms::PeopleList.new(people)).call

    expect(rendered).must_include '<ul class="inline-compact">'
    people.each do |person|
      expect(rendered).must_include person.page_url
    end
  end

  it 'renders a single item as a list' do
    rendered = Bridgetown::TemplateView.render(::Atoms::PeopleList.new([::Person.first])).call

    expect(rendered).must_include '<ul class="inline-compact">'
  end

  it 'raises for an invalid argument' do
    expect { ::Atoms::PeopleList.new(42) }.must_raise(ArgumentError)
  end
end
