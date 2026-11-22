# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/compact_list'

class TestCompactList < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  describe 'comma style' do
    it 'separates multiple items with commas' do
      rendered = Bridgetown::TemplateView.render(::Atoms::CompactList.new(%w[a b], style: :comma)).call

      expect(rendered).must_equal 'a,  b'
    end

    it 'renders a single item without separators' do
      rendered = Bridgetown::TemplateView.render(::Atoms::CompactList.new(%w[a], style: :comma)).call

      expect(rendered).must_equal 'a'
    end
  end

  describe 'sentence style' do
    it 'joins three items with commas and a trailing and' do
      rendered = Bridgetown::TemplateView.render(::Atoms::CompactList.new(%w[a b c], style: :sentence)).call

      expect(rendered).must_equal 'a, b, and c'
    end

    it 'joins two items with and' do
      rendered = Bridgetown::TemplateView.render(::Atoms::CompactList.new(%w[a b], style: :sentence)).call

      expect(rendered).must_equal 'a and b'
    end

    it 'renders a single item' do
      rendered = Bridgetown::TemplateView.render(::Atoms::CompactList.new(%w[a], style: :sentence)).call

      expect(rendered).must_equal 'a'
    end
  end

  describe 'list style' do
    it 'wraps items in an unordered list' do
      rendered = Bridgetown::TemplateView.render(::Atoms::CompactList.new(%w[a b], style: :list)).call

      expect(rendered).must_include '<ul class="inline-compact">'
      expect(rendered).must_include '<li class="inline-compact">a</li>'
    end
  end

  describe 'empty input' do
    it 'renders nothing for an empty list' do
      rendered = Bridgetown::TemplateView.render(::Atoms::CompactList.new([], style: :comma))

      assert_nil rendered
    end
  end

  describe 'validation' do
    it 'rejects a non-array argument' do
      expect { ::Atoms::CompactList.new('not an array') }.must_raise(ArgumentError)
    end

    it 'rejects an unknown style' do
      expect { ::Atoms::CompactList.new(%w[a b], style: :weird) }.must_raise(ArgumentError)
    end
  end
end
