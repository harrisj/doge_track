# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/grid/focused'

class TestFocusedGrid < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  # Find the internal transfer position for Edward Coristine (DHS -> FEMA,
  # 2025-02-05). This is the record that previously produced an empty date
  # block on the person's page.
  def internal_transfer
    ::Position.find(id: 'internal-hhs-fema-edward-coristine')
  end

  describe '#initialize_positions' do
    it 'skips internal transfer positions when building date blocks' do
      focused = ::Grid::Focused.new(person: ::Person['Edward Coristine'])

      # The internal transfer starts on 2025-02-05; that date must not exist as
      # a block since internal transfers are excluded from the positions grid too.
      refute focused.instance_variable_get(:@days).key?(::EDTF.parse('2025-02-05').edtf)
    end

    it 'still records non-internal positions on their start date' do
      focused = ::Grid::Focused.new(person: ::Person['Edward Coristine'])

      # Coristine's first appointment (GSA Senior Advisor) is 2025-01-20.
      assert focused.instance_variable_get(:@days).key?(::EDTF.parse('2025-01-20').edtf)
    end
  end
end
