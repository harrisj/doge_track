# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/position_end_type_label'

class TestPositionEndTypeLabel < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  it 'renders the resigned label' do
    position = ::Position.where(end_type: 'resigned').first
    rendered = Bridgetown::TemplateView.render(::Atoms::PositionEndTypeLabel.new(position: position)).call

    expect(rendered).must_equal 'resigned from agency'
  end

  it 'renders an empty string for an unknown end type' do
    position = ::Position.where(end_type: 'unknown').first
    rendered = Bridgetown::TemplateView.render(::Atoms::PositionEndTypeLabel.new(position: position)).call

    expect(rendered).must_equal ''
  end
end
