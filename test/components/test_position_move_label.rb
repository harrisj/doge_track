# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/position_move_label'

class TestPositionMoveLabel < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  it 'renders a detailed move with destination agency' do
    position = ::Position.where(type: 'detailed').first
    rendered = Bridgetown::TemplateView.render(::Atoms::PositionMoveLabel.new(position: position)).call

    expect(rendered).must_include 'md:text-nowrap'
    expect(rendered).must_include 'link-hover'
  end

  it 'omits the destination when show_dest is false' do
    position = ::Position.find(id: 'imls-hamrick')
    rendered = Bridgetown::TemplateView
               .render(::Atoms::PositionMoveLabel.new(position: position, show_dest: false)).call

    refute_includes rendered, '<a'
  end
end
