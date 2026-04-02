# frozen_string_literal: true

module Atoms
  # A floating box of sources
  class SourceBox < Bridgetown::Component
    def initialize(sources:)
      super()
      @sources = sources
    end

    def source_box_title
      if @sources.count > 1
        'sources'
      else
        'source'
      end
    end

    def source_pub_date(source)
      return unless source.pub_date

      <<~HTML.chomp
        &nbsp;<span class="text-nowrap">#{text -> { source.pub_date }}</span>
      HTML
    end

    def source_item(source)
      <<~HTML
        <li class="text-xs -indent-4"><a target="_blank" href="#{text -> { source.url }}"><cite>#{text -> { source.title }}</cite></a> <i class="fa-sharp fa-solid fa-up-right-from-square"></i> #{text -> { source.publisher.name }}#{html -> { source_pub_date(source) }}</span></li>
      HTML
    end

    def template
      return text -> { '' } if @sources.empty?

      html lambda {
        <<~HTML.chomp
          <div class="float-right pl-2 pb-2">
            <div class="dropdown dropdown-left ml-1 text-sm">
              <div tabindex="0" role="button" aria-label="Sources"> <i class="fa-sharp fa-solid fa-receipt"></i></div>
              <div class="dropdown-content bg-base-100 rounded-box z-1 pb-3 pl-7 shadow-sm text-sm divide-y-1">
                <div class="bg-base-200 -indent-4"><i class="fa-sharp fa-regular fa-receipt"></i> #{text -> { source_box_title }}</div>
                <ul class="list-none w-xs sm:w-sm md:w-md lg:w-lg xl:w-xl">
                  #{html_map(@sources) { |source| html -> { source_item(source) } }}
               </ul>
              </div>
            </div>
          </div>
        HTML
      }
    end
  end
end
