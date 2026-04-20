# frozen_string_literal: true

module Builders
  # Save out a static API
  class GenerateNamePages < SiteBuilder
    def build
      Person.each do |person|
        add_resource :names, "#{person.slug}.md" do
          layout :page
          title person.name
          content "{%@ 'person_page', person: Person['#{person.name}'] %}"
        end
      end
    end
  end
end
