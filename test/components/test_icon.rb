# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/icon'

class TestIcon < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  it 'looks up the FontAwesome class for a known icon name' do
    expect(::Atoms::Icon.new('access').icon_css).must_equal 'fa-database'
  end

  it 'passes through an explicit FontAwesome class' do
    expect(::Atoms::Icon.new('fa-flag').icon_css).must_equal 'fa-flag'
  end

  it 'falls back to a fallback icon for an unknown name' do
    expect(::Atoms::Icon.new('definitely-not-an-icon').icon_css).must_equal 'fa-circle-question'
  end

  it 'renders an empty class list for a nil icon name' do
    expect(::Atoms::Icon.new(nil).icon_css).must_equal ''
  end

  it 'resolves the aria label from the icon registry' do
    expect(::Atoms::Icon.new('access').aria).must_equal 'System Access'
  end

  it 'returns nil for the aria label when aria is disabled' do
    refute ::Atoms::Icon.new('access', aria: false).aria
  end

  it 'returns the custom aria string when supplied' do
    expect(::Atoms::Icon.new('access', aria: 'Custom').aria).must_equal 'Custom'
  end

  it 'renders the icon markup with the FontAwesome class' do
    rendered = render_component(::Atoms::Icon.new('access'))

    expect(rendered).must_include '<i class="fa-sharp fa-solid fa-database fa-fw"'
    expect(rendered).must_include 'title="System Access"'
  end
end
