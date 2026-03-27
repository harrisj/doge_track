# frozen_string_literal: true

require 'minitest_helper'
require 'edtf_format'

class TestEdtfComponent < Bridgetown::Test
  def test_exact_date_iso_format
    d = EdtfFormat.new('2023-02-02', :iso)
    expect(d.render_in(false)) == '2023-02-02'
  end
end
