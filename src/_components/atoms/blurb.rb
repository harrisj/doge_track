# frozen_string_literal: true

module Atoms
  # Markdownify, delete <p> tags and even linkify in one package!
  class Blurb < Bridgetown::Component
    def initialize(text, linkify: false, markdownify: true, strip_p: true)
      super()
      @text = text.dup
      @linkify = linkify
      @site = Bridgetown::Current.site
      @markdownify = markdownify
      @strip_p = strip_p
    end

    def replace_names!(text)
      Person.each do |person|
        if text.include?(person.name)
          text.gsub!(/\b#{person.name}\b/, Bridgetown::TemplateView.render(Atoms::PersonLink.new(person.name)).call)
        end
      end
    end

    def replace_agencies!(text)
      Agency.each do |agency|
        next unless agency.linkify

        if text.include?(agency.id) && (agency.id =~ /^[A-Z]+$/) && (agency.id =~ /^[A-Z]+$/)
          text.gsub!(/\b#{agency.id}\b/,
                     Bridgetown::TemplateView.render(Atoms::AgencyLink.new(agency.id)).call)
        end

        if text.include?(agency.name)
          text.gsub!(/\b#{agency.name}\b/,
                     Bridgetown::TemplateView.render(Atoms::AgencyLink.new(agency.id, display: agency.name)).call)
        end
      end
    end

    def template
      return text -> { '' } if @text.nil?

      out = @text.dup

      if @linkify
        replace_names!(out)
        replace_agencies!(out)
      end

      if @markdownify
        converter = @site.find_converter_instance(Bridgetown::Converters::Markdown)
        # content = Bridgetown::Utils.reindent_for_markdown(out)
        out = converter.convert(out).strip
      end

      out.gsub!(%r{</?p>}, '') if @strip_p

      html -> { out }
    end
  end
end
