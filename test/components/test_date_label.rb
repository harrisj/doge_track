# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/date_label'

class TestDateLabel < Bridgetown::Test
  describe 'single date rendering' do
    subject do
      ::Atoms::DateLabel.new(Date.new(2025, 10, 1))
    end

    before do
      @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
      Bridgetown::Current.site = @site
    end

    it 'renders the compact year format' do
      rendered = Bridgetown::TemplateView.render(subject).call

      expect(rendered).must_equal '10/01/25'
    end

    it 'renders the iso format' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new(Date.new(2025, 10, 1), date_format: :iso)).call

      expect(rendered).must_equal '2025-10-01'
    end
  end

  describe 'interval rendering' do
    subject do
      ::Atoms::DateLabel.new('2025-01-20/2025-12-31')
    end

    before do
      @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
      Bridgetown::Current.site = @site
    end

    it 'renders the interval range in the compact year format' do
      rendered = Bridgetown::TemplateView.render(subject).call

      expect(rendered).must_equal '1/20/25–12/31/25'
    end

    it 'renders the interval range in the iso format' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new('2025-01-20/2025-12-31',
                                                                        date_format: :iso)).call

      expect(rendered).must_equal '2025-01-20–2025-12-31'
    end

    it 'renders the interval range in the compact format' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new('2025-01-20/2025-12-31',
                                                                        date_format: :compact)).call

      expect(rendered).must_equal '1/20–12/31'
    end

    it 'renders only the start bound when interval_display is :start' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new('2025-01-20/2025-12-31',
                                                                        interval_display: :start)).call

      expect(rendered).must_equal '≥1/20/25'
    end

    it 'renders only the end bound when interval_display is :end' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new('2025-01-20/2025-12-31',
                                                                        interval_display: :end)).call

      expect(rendered).must_equal '≤12/31/25'
    end
  end
end
