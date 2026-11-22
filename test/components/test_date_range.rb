# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/date_range'

class TestDateRange < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  def render(range)
    rendered = Bridgetown::TemplateView.render(range)

    rendered.respond_to?(:call) ? rendered.call : rendered
  end

  describe 'default date range rendering' do
    it 'is not null' do
      range = ::Atoms::DateRange.new(start_date: Date.new(2025, 10, 1), end_date: Date.new(2025, 10, 7))

      expect(range).wont_be_nil
    end

    it 'uses the compact date/year format' do
      range = ::Atoms::DateRange.new(start_date: Date.new(2025, 10, 1), end_date: Date.new(2025, 10, 7))

      expect(render(range)).must_equal '<span class="md:text-nowrap my-date">10/01/25-10/07/25</span>'
    end

    it 'renders a nil end date as a single date' do
      range = ::Atoms::DateRange.new(start_date: Date.new(2025, 10, 1), end_date: nil)

      expect(render(range)).must_equal '<span class="md:text-nowrap my-date">10/01/25</span>'
    end

    it 'renders a single date when only the end date is given' do
      range = ::Atoms::DateRange.new(start_date: nil, end_date: Date.new(2025, 10, 1))

      expect(render(range)).must_equal '<span class="md:text-nowrap my-date">-10/01/25</span>'
    end

    it 'renders an empty string when neither date is given' do
      assert_nil render(::Atoms::DateRange.new)
    end
  end

  describe 'interval rendering' do
    it 'renders the interval range' do
      range = ::Atoms::DateRange.new(start_date: '2025-01-20/2025-12-31', end_date: nil)

      expect(render(range))
        .must_equal(
          '<span class="md:text-nowrap my-date"><abbr title="On or after Jan 20, 2025">≥1/20/25</abbr></span>'
        )
    end

    it 'uses the iso format' do
      range = ::Atoms::DateRange.new(start_date: '2025-01-20/2025-12-31', end_date: nil, date_format: :iso)

      expect(render(range))
        .must_equal '<span class="md:text-nowrap my-date"><abbr title="On or after Jan 20, 2025">≥2025-01-20</abbr></span>'
    end
  end

  describe 'always dash' do
    it 'keeps the dash when both dates are nil but always_dash is set' do
      range = ::Atoms::DateRange.new(start_date: Date.new(2025, 10, 1),
                                     end_date: nil, always_dash: true)

      expect(render(range)).must_equal '<span class="md:text-nowrap my-date">10/01/25-</span>'
    end

    it 'omits the dash for a single date when always_dash is false' do
      range = ::Atoms::DateRange.new(start_date: Date.new(2025, 10, 1), end_date: nil)

      expect(render(range)).must_equal '<span class="md:text-nowrap my-date">10/01/25</span>'
    end
  end
end
