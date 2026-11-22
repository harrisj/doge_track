# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/compact_list'
require_relative '../../src/_components/atoms/agencies_list'

class TestAgenciesList < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  it 'links each agency in the list' do
    agencies = ::Agency.limit(2).all
    rendered = Bridgetown::TemplateView.render(::Atoms::AgenciesList.new(agencies)).call

    expect(rendered).must_include '<ul class="inline-compact">'
    agencies.each do |agency|
      expect(rendered).must_include agency.page_url
    end
  end

  it 'renders a single item as a list' do
    rendered = Bridgetown::TemplateView.render(::Atoms::AgenciesList.new([::Agency.first])).call

    expect(rendered).must_include '<ul class="inline-compact">'
  end

  it 'raises for an invalid argument' do
    expect { ::Atoms::AgenciesList.new(42) }.must_raise(ArgumentError)
  end
end
