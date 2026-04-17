# frozen_string_literal: true

require 'minitest_helper'

class TestHomepage < Bridgetown::Test
  describe 'index' do
    it 'has a body and a drawer' do
      html get '/'

      expect(document.query_selector('body').inner_html)
    end
  end
end
