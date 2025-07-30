# frozen_string_literal: true

require 'date'
require 'yaml'
require 'fileutils'
require 'edtf-humanize'
require 'kramdown'

require 'sequel'
DB_PATH = File.join(File.dirname(__FILE__), '..', 'doge.sqlite')
DB = Sequel.sqlite(DB_PATH)

require 'require_all'
require_all File.join(File.dirname(__FILE__), '..', '..', 'models')

def internal_link(url, display)
  "<a class=\"link-hover\" href=\"#{url}\">#{display}</a>"
end

def linkify_text(text)
  return nil if text.nil?

  out = text.dup

  ExecutiveOrder.each do |eo|
    out.gsub!(/\bEO #{eo.id}\b/, internal_link("/projects/exec-orders/#eo-#{eo.id}", "EO #{eo.id}"))
  end

  Person.each do |person|
    out.gsub!(/\b#{person.name}\b/, internal_link(person.page_url, person.name))
  end

  DogeAlias.each do |doge_alias|
    if doge_alias.person
      out.gsub!(/\b#{doge_alias.id}\b/,
                "#{doge_alias.id} (#{internal_link(doge_alias.person.page_url, doge_alias.person.name)})")
    end
  end

  Agency.each do |agency|
    out.gsub!(/\b#{agency.id}(?=[\s.,!])/, internal_link(agency.page_url, agency.id)) if agency.id =~ /^[A-Z]+$/
    out.gsub!(/\b#{agency.name}\b/, internal_link(agency.page_url, agency.name))
  end

  Kramdown::Document.new(out).to_html.gsub(%r{</?p>}, '')
end

ExecutiveOrder.each do |eo|
  eo.linkified_summary = linkify_text(eo.summary)
  eo.save_changes
end

Event.each do |e|
  e.linkified_text = linkify_text(e.text)
  e.save_changes
end

Agency.each do |a|
  a.linkified_blurb = linkify_text(a.blurb)
  a.save_changes
end

Person.each do |p|
  p.linkified_blurb = linkify_text(p.blurb)
  p.save_changes
end

DogeAlias.each do |a|
  a.linkified_evidence = linkify_text(a.evidence)
  a.save_changes
end
