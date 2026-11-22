# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/date_label'

class TestDateLabel < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  describe 'single date rendering' do
    it 'renders the compact year format' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new(Date.new(2025, 10, 1))).call

      expect(rendered).must_equal '10/01/25'
    end

    it 'renders the iso format' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new(Date.new(2025, 10, 1), date_format: :iso)).call

      expect(rendered).must_equal '2025-10-01'
    end

    it 'renders the compact format without the year' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new(Date.new(2025, 10, 1),
                                                                        date_format: :compact)).call

      expect(rendered).must_equal '10/01'
    end

    it 'renders a string EDTF date by parsing it' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new('2025-10-01')).call

      expect(rendered).must_equal '10/01/25'
    end

    it 'renders an empty string for a nil date' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new(nil)).call

      expect(rendered).must_equal ''
    end
  end

  describe 'interval rendering' do
    it 'renders the interval range in the compact year format' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new('2025-01-20/2025-12-31')).call

      expect(rendered)
        .must_equal '<abbr title="On or after Jan 20, 2025">≥1/20/25</abbr>'
    end

    it 'renders the interval range in the iso format' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new('2025-01-20/2025-12-31',
                                                                        date_format: :iso)).call

      expect(rendered)
        .must_equal '<abbr title="On or after Jan 20, 2025">≥2025-01-20</abbr>'
    end

    it 'renders the interval range in the compact format' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new('2025-01-20/2025-12-31',
                                                                        date_format: :compact)).call

      expect(rendered)
        .must_equal '<abbr title="On or after Jan 20, 2025">≥1/20</abbr>'
    end

    it 'renders only the start bound when interval_display is :start' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new('2025-01-20/2025-12-31',
                                                                        interval_display: :start)).call

      expect(rendered)
        .must_equal '<abbr title="On or after Jan 20, 2025">≥1/20/25</abbr>'
    end

    it 'renders only the end bound when interval_display is :end' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new('2025-01-20/2025-12-31',
                                                                        interval_display: :end)).call

      expect(rendered)
        .must_equal '<abbr title="On or before Dec 31, 2025">≤12/31/25</abbr>'
    end
  end

  describe 'unspecified, approximate and uncertain dates' do
    it 'renders an unspecified day with a month/year hint' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new('2025-08-XX')).call

      expect(rendered).must_equal '<abbr title="Sometime in Aug 2025">8/XX/25</abbr>'
    end

    it 'renders an approximate date with a c. prefix' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new('2025-08-15~')).call

      expect(rendered).must_equal '<abbr title="On or around Aug 15, 2025">c.8/15/25</abbr>'
    end

    it 'renders an uncertain date with a trailing question mark' do
      rendered = Bridgetown::TemplateView.render(::Atoms::DateLabel.new('2025-08-15?')).call

      expect(rendered).must_equal '<abbr title="Possibly Aug 15, 2025">8/15/25?</abbr>'
    end
  end

  describe 'validation' do
    it 'rejects an unknown interval display mode' do
      expect { ::Atoms::DateLabel.new(Date.new(2025, 10, 1), interval_display: :middle) }
        .must_raise(ArgumentError)
    end

    it 'rejects an unknown date format' do
      expect { ::Atoms::DateLabel.new(Date.new(2025, 10, 1), date_format: :weird) }
        .must_raise(ArgumentError)
    end
  end
end
