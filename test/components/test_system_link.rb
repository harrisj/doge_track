# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/system_link'

class TestSystemLink < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  it 'links to a govt system by acronym' do
    system = ::GovtSystem.first
    rendered = Bridgetown::TemplateView.render(::Atoms::SystemLink.new(system)).call

    expect(rendered).must_equal(
      %(<a class="link-hover" href="#{system.page_url}" title="#{system.name}">#{system.acronym}</a>)
    )
  end

  it 'expands the name when the system has an acronym' do
    system = ::GovtSystem.first
    rendered = Bridgetown::TemplateView.render(::Atoms::SystemLink.new(system, expanded: true)).call

    expect(rendered)
      .must_equal(
        %(<a class="link-hover" href="#{system.page_url}" title="#{system.name}">#{system.acronym}</a>) +
        ": #{system.name}\n"
      )
  end

  it 'raises for a missing system when raise_miss is true' do
    expect { ::Atoms::SystemLink.new('DOES-NOT-EXIST', raise_miss: true) }
      .must_raise(Sequel::NoMatchingRow)
  end
end
