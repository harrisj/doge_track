# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/person_link'

class TestPersonLink < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  it 'links to a person by record' do
    person = ::Person.first
    rendered = render_component(::Atoms::PersonLink.new(person))

    expect(rendered).must_equal %(<a class="link-hover" href="#{person.page_url}">#{person.name}</a>)
  end

  it 'looks up a person by name' do
    person = ::Person.first
    rendered = render_component(::Atoms::PersonLink.new(person.name))

    expect(rendered).must_equal %(<a class="link-hover" href="#{person.page_url}">#{person.name}</a>)
  end

  it 'uses a custom display name' do
    person = ::Person.first
    rendered = render_component(::Atoms::PersonLink.new(person, display: 'Custom'))

    expect(rendered).must_equal %(<a class="link-hover" href="#{person.page_url}">Custom</a>)
  end

  it 'returns the raw name as text when no person is found' do
    rendered = render_component(::Atoms::PersonLink.new('Nobody Here', raise_miss: false))

    expect(rendered).must_equal 'Nobody Here'
  end

  it 'raises for a missing name when raise_miss is true' do
    expect { ::Atoms::PersonLink.new('Nobody Here', raise_miss: true) }
      .must_raise(Sequel::NoMatchingRow)
  end
end
