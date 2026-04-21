---
layout: docs
title: Who's Involved in DOGE
description: An alphabetical listing of all the people being tracked as part of the DOGE tracker
index_for_search: true
text_updated: 2026-02-23
---
{%@ Atoms::Title title: "Who's Involved in DOGE" %}

DOGE is very difficult to track. The Trump Administration has used every tool at its disposal to make it difficult to see where DOGE has been staffed to a particular agency, whether they direct hires or one of DOGE's [many details](details/) of staff from one agency to go work at another. This page provides a single overview of everybody who is is my database of DOGE affiliates, sourced from news reports and court documents. The chart below of DOGE staffing levels is **grossly inaccurate** – for instance, there are likely dozens of people who have departed DOGE without leaving a public record of their exit. It does however illustrate how DOGE continues to maintain its presence in agencies, despite multiple reports over the last few months of its demise.

<div id="chart"></div>
<script src="/includes/doge_totals.js"></script>

Here are the current members of DOGE that I have linked to specific positions, listed with their likely start dates if known or when they were first spotted in an agency. If they have exited the government, that date is also presented here. Otherwise, the table reports when they were last explicitly named in a news report or court filing as being present in a government role.

<div class="tabs tabs-border mt-10">
  <input type="radio" name="people-tabs" class="tab" aria-label="Starts By Date" checked="checked" />
  <div class="tab-content">
    {% people = Person.eager_graph({positions: :agency}).order(:sort_date, Sequel[:agency][:name], :sort_name).all %}

    {% last_key = "" %}
    <table class="table table-xs md:table-sm xl:table-md py-5 mb-0 table-zebra">
        <thead>
            <tr>
                <th class="align-left">Start</th>
                <th class="align-left">Agency</th>
                <th class="align-left">Name</th>
                <th class="align-left hide-cell-mobile">Skill</th>
                <th class="align-left">Last Seen</th>
            </tr>
        </thead>
        <tbody>
        {% people.each do |person| %}
            {% next unless person.positions.first.start_date %}
            {% key = "#{person.sort_date}-#{person.positions.first.agency_id}}}" %}
            <tr>
                <td class="align_left align-top text-nowrap">{% if key != last_key %}{%@ Atoms::Icon 'appointed'%} {%@ Atoms::DateLabel person.positions.first.sort_date, date_format: :iso %}{% end %}</td>
                <td class="align-left align-top">{%@ Atoms::AgencyLink person.positions.first.agency_id %}</td>
                <td class="align-left align-top">{%@ Atoms::PersonLink person %}</td>
                <td class="align-left align-top hide-cell-mobile">{{ person_skill(person) }}</td>
                <td class="align-left align-top text-nowrap">{% if person.govt_exit_date %}<b>{%@ Atoms::Icon 'offboard' %} {%@ Atoms::DateLabel person.govt_exit_date, date_format: :iso %}{% if person.govt_exit_truth == 'guessed' %}?{% end %}</b>{% elsif person.events.any? %}{% last_event = person.events.last %}{%@ Atoms::Icon 'sighting' %} {%@ Atoms::DateLabel last_event.date, date_format: :iso %}{% end %}</td>
            </tr>
            {% last_key = key %}
        {% end %}
        </tbody>
    </table>
  </div>

  <input type="radio" name="people-tabs" class="tab" aria-label="Changes by Month"/>
    <div class="tab-content">
        {% grouped_by_start = Person.all.reject {|p| p.start_date.nil? }.group_by {|p| p.start_date.strftime("%Y-%m") } %}
        {% grouped_by_end = Person.all.reject {|p| p.govt_exit_date.nil? }.group_by {|p| p.govt_exit_date.strftime("%Y-%m") } %}

        {% start_date = Date.new(2025, 1, 20) %}
        {% current_date = Date.today %}
        <table class="my-table-style">
            <thead>
                <th class="my-2col-table-col1">Month</th>
                <th class="my-2col-table-col2">Names</th>
            </thead>
            <tbody>
                {% while start_date <= current_date %}
                   {% key = start_date.strftime("%Y-%m") %}
                    <tr>
                        <td class="my-2col-table-col1 align-top">{{ start_date.strftime("%b %Y") }}</td>
                        <td class="my-2col-table-col2 align-top">
                        <div class="flex flex-col gap-2">
                        {% if grouped_by_start[key] %}<div>{%@ Atoms::Icon 'onboard' %} {%@ Atoms::PeopleList grouped_by_start[key], style: :comma %}</div>{% end %}
                        {% if grouped_by_end[key] %}<div>{%@ Atoms::Icon 'offboard' %} {%@ Atoms::PeopleList grouped_by_end[key], style: :comma %}</div>{% end %}
                        </div>
                        </td>
                    </tr>
        
                   {% start_date = start_date >> 1 %}
                {% end %}
            </tbody>
        </table>
     </div>
</div>


