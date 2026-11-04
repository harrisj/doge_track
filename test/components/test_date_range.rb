# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/date_range'

class TestDateRange < Bridgetown::Test
  describe 'default date range rendering' do
    subject do
      start_date = Date.new(2025, 10, 1)
      end_date = Date.new(2025, 10, 7)
      ::Atoms::DateRange.new(start_date: start_date, end_date: end_date)
    end

    before do
      @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
      Bridgetown::Current.site = @site
    end

    it 'is not null' do
      expect(subject).wont_be_nil
    end

    it 'uses the compact date/year format' do
      rendered = Bridgetown::TemplateView.render(subject).call

      expect(rendered).must_equal '<span class="md:text-nowrap my-date">10/01/25-10/07/25</span>'
    end
  end

  describe 'interval rendering' do
    subject do
      start_date = '2025-01-20/2025-12-31'
      end_date = nil
      ::Atoms::DateRange.new(start_date: start_date, end_date: end_date)
    end

    before do
      @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
      Bridgetown::Current.site = @site
    end

    it 'renders the interval range' do
      rendered = Bridgetown::TemplateView.render(subject).call

      expect(rendered).must_equal '<span class="md:text-nowrap my-date">≥1/20/25</span>'
    end
  end
end
