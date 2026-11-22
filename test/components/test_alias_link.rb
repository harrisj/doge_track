# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/alias_link'

class TestAliasLink < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  it 'links to a doge alias by record' do
    alias_ = ::DogeAlias.first
    rendered = render_component(::Atoms::AliasLink.new(alias_))

    expect(rendered).must_equal %(<a class="link-hover" href="/people/aliases##{alias_.id}">#{alias_.id}</a>)
  end

  it 'uses a custom display name' do
    alias_ = ::DogeAlias.first
    rendered = render_component(::Atoms::AliasLink.new(alias_, display: 'Custom'))

    expect(rendered).must_equal %(<a class="link-hover" href="/people/aliases##{alias_.id}">Custom</a>)
  end

  it 'looks up an alias by id' do
    rendered = render_component(::Atoms::AliasLink.new(::DogeAlias.first.id))

    expect(rendered).must_include 'link-hover'
  end

  it 'raises for a missing id when raise_miss is true' do
    expect { ::Atoms::AliasLink.new('DOES-NOT-EXIST', raise_miss: true) }
      .must_raise(Sequel::NoMatchingRow)
  end

  it 'returns empty text for a nil alias' do
    rendered = render_component(::Atoms::AliasLink.new(nil, raise_miss: false))

    expect(rendered).must_equal ''
  end
end
