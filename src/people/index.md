---
layout: docs
title: Who's Involved in DOGE
description: An alphabetical listing of all the people being tracked as part of the DOGE tracker
index_for_search: true
text_updated: 2026-02-02
---
{%@ 'atoms/title', title: "Who's Involved in DOGE" %}

DOGE is very difficult to track. The Trump Administration has used every tool at its disposal to make it difficult to see where DOGE has been staffed to a particular agency, whether they direct hires or one of DOGE's [many details](details/) of staff from one agency to go work at another. This page provides a single overview of everybody who is is my database of DOGE affiliates, sourced from news reports and court documents. The chart below of DOGE staffing levels is **grossly inaccurate** – for instance, there are likely dozens of people who have departed DOGE without leaving a public record of their exit. It does however illustrate how DOGE continues to maintain its presence in agencies, despite multiple reports over the last few months of its demise.

<div id="chart"></div>
<script src="/includes/doge_totals.js"></script>

To better understand the types of roles I've seen within DOGE, I have sorted them into several distinct categories of my own design. These are demarcated with specific icons in tables and text where convenient:

- <i class="fa-sharp fa-solid fa-megaphone"></i> <strong>{{ link_to "Boosters", "/people/leaders/" }}</strong> are people in DOGE's orbit who have helped with recruitment and establishing the organization.
- <i class="fa-sharp fa-solid fa-door-open"></i> <strong>{{ link_to "Enablers", "/people/enablers/" }}</strong> are staff embedded in agencies who work to open the door for wreckers to come in. They are not always DOGE hires.
- <i class="fa-sharp fa-solid fa-briefcase"></i> <strong>{{ link_to "Leaders", "/people/leaders/" }}</strong> are the identified and hidden leaders of the operation
- <i class="fa-sharp fa-solid fa-chair-office"></i> <strong>{{ link_to "Support", "/people/support-team/" }}</strong> are the home team, largely based in DOGE and OPM and there to support operations
- <i class="fa-sharp fa-solid fa-bomb"></i> <strong>{{ link_to "Wreckers", "/people/wreckers/" }}</strong> are the away team and the muscle, dispatched to descend on agencies to infiltrate operations, exfiltrate data and possibly destroy entirely

Like any categorization, this is an approximation that provides useful clarity but also masks the messy nuances of reality. I have no idea if DOGE has their own internal categories and how well these map to their own. My categorization also does not account for people changing their roles over time. For instance, {{ person_link("Scott Coulter") }} originally would have been classified as a Wrecker since he was detailed into other agencies like NASA, but I have reclassified him as an Enabler since he was promoted to a Chief Information Officer at Social Security.

Here are the current members of DOGE that I know about, listed with their likely start dates if known or when they were first spotted in an agency. If they have exited the government, that date is also presented here. Otherwise, the table reports when they were last explicitly named in a news report or court filing as being present in a government role.

{% people = Person.eager_graph(:positions).order(:sort_name, :sort_date).all %}

<table class="my-table-style table-zebra">
<thead>
  <tr>
      <th class="align-left w-[14px] hidden sm:table-cell"></th>
      <th class="align-left">Name</th>
      <th class="align-left">Skill</th>
      <th class="align-left">Start</th>
      <th class="align-left">Status</th>
      <th class="align-left hide-cell-mobile">Agencies</th>
  </tr>
</thead>
<tbody>
{% people.each do |person| %}
    <tr>
        <td class="align-left align-top hidden sm:table-cell w-[14px]"><i class="fa-sharp fa-solid {{ person_icon(person) }}"></i></td>
        <td class="align-left align-top">{{ person_link(person) }}</td>
        <td class="align-left align-top text-nowrap">{{ person_skill(person) }}</td>
        <td class="align_left align-top text-nowrap">{% if person.start_date %}<i class="fa-sharp fa-solid fa-person-to-door" aria-label="Started"></i> {{ render EdtfFormat.new(person.positions.first.start_date, :iso) }}{% if person.positions.first.start_date_truth == 'guessed' %}?{% end %}{% elsif person.events.any? %}<i class="fa-sharp fa-solid fa-users-viewfinder" aria-label="First spotted"></i> {{ render EdtfFormat.new(person.events.first.date, :iso) }}{% end %}</td>
        <td class="align-left align-top text-nowrap">{% if person.govt_exit_date %}<b><i class="fa-sharp fa-solid fa-left-from-bracket" aria-label="Left DOGE"></i> {{ render EdtfFormat.new(person.govt_exit_date, :iso) }}{% if person.govt_exit_truth == 'guessed' %}?{% end %}</b>{% elsif person.events.any? %}{% last_event = person.events.last %}<i class="fa-sharp fa-solid fa-users-viewfinder" aria-label="Most recently spotted"></i> {{ render EdtfFormat.new(last_event.date, :iso) }}{% end %}</td>
        <td class="align-left align-top hide-cell-mobile">{% if person.positions.any? %}{{ person.positions.map(&:agency_id) | uniq | agency_links }}{% end %}</td>
    </tr>
{% end %}
</tbody>
</table>
