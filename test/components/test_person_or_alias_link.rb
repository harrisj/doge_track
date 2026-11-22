# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/person_or_alias_link'

class TestPersonOrAliasLink < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  it 'links to a person passed as a record' do
    person = ::Person.first
    rendered = render_component(::Atoms::PersonOrAliasLink.new(person))

    expect(rendered).must_include person.page_url
  end

  it 'links to a person passed by name' do
    person = ::Person.first
    rendered = render_component(::Atoms::PersonOrAliasLink.new(person.name))

    expect(rendered).must_include person.page_url
  end

  it 'links to an alias passed by id' do
    alias_ = ::DogeAlias.first
    rendered = render_component(::Atoms::PersonOrAliasLink.new(alias_.id))

    expect(rendered).must_include("/people/aliases##{alias_.id}")
  end

  it 'uses a custom display name' do
    person = ::Person.first
    rendered = render_component(::Atoms::PersonOrAliasLink.new(person, display: 'Custom'))

    expect(rendered).must_include 'Custom'
  end

  it 'returns the raw name as text when no record is found' do
    rendered = render_component(::Atoms::PersonOrAliasLink.new('Nobody Here', raise_miss: false))

    expect(rendered).must_equal 'Nobody Here'
  end

  it 'raises for an unknown identifier when raise_miss is true' do
    expect { ::Atoms::PersonOrAliasLink.new('Nobody Here', raise_miss: true) }
      .must_raise(Sequel::NoMatchingRow)
  end
end
