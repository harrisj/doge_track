# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/agency_link'

class TestAgencyLink < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  it 'links to an agency by its record' do
    agency = ::Agency.first
    rendered = Bridgetown::TemplateView.render(::Atoms::AgencyLink.new(agency)).call

    expect(rendered).must_match(
      %r{<a class="link-hover" href="/agencies/[^"]+">#{Regexp.escape(agency.short_name)}</a>}
    )
  end

  it 'uses a custom display name' do
    agency = ::Agency.first
    rendered = Bridgetown::TemplateView.render(::Atoms::AgencyLink.new(agency, display: 'Custom')).call

    expect(rendered).must_equal %(<a class="link-hover" href="#{agency.page_url}">Custom</a>)
  end

  it 'renders plain text when linking is disabled' do
    agency = ::Agency.first
    rendered = render_component(::Atoms::AgencyLink.new(agency, link: false))

    expect(rendered).must_equal agency.short_name
  end

  it 'looks up an agency by id' do
    rendered = Bridgetown::TemplateView.render(::Atoms::AgencyLink.new(::Agency.first.id)).call

    expect(rendered).must_include 'link-hover'
  end

  it 'raises for a missing agency id when raise_miss is true' do
    expect { ::Atoms::AgencyLink.new('DOES-NOT-EXIST', raise_miss: true) }
      .must_raise(Sequel::NoMatchingRow)
  end

  it 'returns empty text for a nil agency' do
    rendered = render_component(::Atoms::AgencyLink.new(nil, raise_miss: false))

    expect(rendered).must_equal ''
  end
end
