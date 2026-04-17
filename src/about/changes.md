---
title: What's Changed
layout: docs
text_updated: 2025-09-21
---
# What's Changed?

This is not a definitive list of all changes to the project (completists can always do diffs on the [GitHub repo](https://github.com/harrisj/doge_track)), but this page is a list of **new** records about people, positions and events with notes on other significant changes. Each week is listed with the total number of lines added and removed just in the source data and pages; click on it to expand into more details about the new records. Since this project is built on information from news sources and court documents, _"new"_ records in a given week may include events that occurred weeks or even months earlier. That is not a bug, but a reflection on how slowly details can trickle out about DOGE's operations.

{% import 'macros' %}
{% seen_events = [] %}

{% site.data.changes.each do |rec| %}
<div class="collapse bg-base-100 border border-base-300">
  <input type="radio" name="change-log-accordion"/>

  <div class="collapse-title flex justify-between leading-none items-center">
    <div class="font-semibold text-xl">Week of {{ rec.start }}</div>
    <div class="font-mono"><span class="text-nowrap">+{{rec.added}}</span> <span class="text-nowrap">-{{rec.deleted}}</span></div>
  </div>
  <div class="collapse-content">

{% if rec.notes && rec.notes.any? %}
<ul class="leading-tight mt-0">
{% rec.notes.each do |note| %}
<li>{%@ Atoms::Blurb note %}</li>
{% end %}
<li><a href="https://github.com/harrisj/doge_track/commits/main/?since={{ rec.start }}&until={{ rec.end }}">[View All Changes]</a></li>
</ul>
{% end %}

{% if rec.names.any? %}
<h2 class="text-lg mt:2">Names Added</h2>

<p>{%@ Atoms::PeopleList rec.names, raise_miss: false %}</p>
{% end %}

{% if rec.positions.any? %}
<h2 class="text-lg mt:2">Positions Added</h2>

{% positions = rec.positions.map {|e_id| Position[e_id]}.compact %}
{%@ 'tables/agency_positions', positions: positions, agency: nil %}
{% end %}

{% if rec.events.any? %}
<h2 class="text-lg mt:2">Events Added</h2>

{% events = Event.eager_graph(:agencies, :people).where({Sequel[:events][:id] => rec.events}).order(:date).all.compact %}
{%@ Table::Events events, month_separator: false %}
{% end %}
  </div>
</div>
{% end %}
