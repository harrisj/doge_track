# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/title'

class TestTitle < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  it 'renders a heading with the given title' do
    rendered = render_component(::Atoms::Title.new(title: 'Hello'))

    expect(rendered)
      .must_equal "<h1 class=\"font-title text-2xl sm:text-3xl md:text-4xl mb-4\">Hello</h1>\n"
  end
end
