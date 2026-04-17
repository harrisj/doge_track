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

    it 'is not null' do
      expect(subject).wont_be_nil
    end

    it 'uses the compact date/year format' do
      rendered = Bridgetown::TemplateView.render(subject).call

      expect(rendered).must_equal '<span class="md:text-nowrap my-date"></span>'
    end
  end
end
