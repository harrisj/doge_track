# frozen_string_literal: true

require 'date'
require 'yaml'
require 'fileutils'
require 'edtf-humanize'
require 'kramdown'

require 'sequel'
DB_PATH = File.join(File.dirname(__FILE__), '..', 'doge.db')
DB = Sequel.sqlite(DB_PATH)

require 'require_all'
require_all File.join(File.dirname(__FILE__), '..', '..', 'models')

def internal_link(url, display)
  "<a class=\"link-hover\" href=\"#{url}\">#{display}</a>"
end

def linkers_eo
  ExecutiveOrder.all.map do |eo|
    [
      Regexp.new("\\bEO #{Regexp.escape(eo.id.to_s)}\\b"),
      internal_link("/projects/exec-orders/#eo-#{eo.id}", "EO #{eo.id}")
    ]
  end
end

def linkers_people
  Person.all.sort_by { |p| -p.name.length }.map do |p|
    [
      Regexp.new("\\b#{Regexp.escape(p.name)}\\b"),
      internal_link(p.page_url, p.name)
    ]
  end
end

def linkers_agencies
  Agency.where(linkify: true).all.sort_by { |a| -a.name.length }.flat_map do |a|
    [
      [Regexp.new("\\b#{Regexp.escape(a.id)}(?=[\\s.,!])"), internal_link(a.page_url, a.id)],
      [Regexp.new("\\b#{Regexp.escape(a.name)}\\b"), internal_link(a.page_url, a.name)]
    ]
  end
end

def linkers_aliases
  people = Person.all.to_h { |p| [p.name, p] }
  DogeAlias.where(name: people.keys).map do |a|
    person = people[a.name]
    next unless person

    replacement = "#{a.id} (#{internal_link(person.page_url, person.name)})"
    [
      Regexp.new("\\b#{Regexp.escape(a.id)}\\b"),
      replacement
    ]
  end.compact
end

# Build matchers ONCE, longest token first so longer names win over substrings.
# Tokens are Regexp.escape'd so names with regex metacharacters (`.`, `+`, etc.)
# match literally instead of breaking the pattern.
LINKERS = {
  eo: linkers_eo,
  people: linkers_people,
  agencies: linkers_agencies,
  aliases: linkers_aliases
}.freeze

def linkify_text(text, strip_p: true)
  return nil if text.nil?

  out = text.dup
  %i[eo people agencies aliases].each do |cat|
    LINKERS[cat].each { |re, rep| out.gsub!(re, rep) }
  end

  out = Kramdown::Document.new(out).to_html
  out.gsub!(%r{</?p>}, '') if strip_p

  out
end

DB.transaction do
  ExecutiveOrder.all.each { |eo| eo.update(linkified_summary: linkify_text(eo.summary)) }
  Event.all.each { |e| e.update(linkified_text: linkify_text(e.text)) }
  Agency.all.each { |a| a.update(linkified_blurb: linkify_text(a.blurb, strip_p: false)) }
  Person.all.each { |p| p.update(linkified_blurb: linkify_text(p.blurb, strip_p: false)) }
  DogeAlias.all.each { |a| a.update(linkified_evidence: linkify_text(a.evidence)) }
end
