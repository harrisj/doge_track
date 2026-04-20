---
layout: page
template_engine: serbea
title: All Events
description: A comprehensive listing of all the events of DOGE staff on a single page
---
{%@ Atoms::Title title: 'All The Events' %}

<p class="my-text">For the maximalists (and my debugging), here is a page with all of the events that happened in order.</p>

<div><i class="fa-sharp fa-solid fa-file-csv"></i> <a href="/csv/events.csv">Download as CSV</a></div>
{% events = Event.eager_graph(:people, :doge_aliases, :agencies).order(:date).all %}

<div class="data-grid not-prose">
{%@ Grid::Focused events: events %}
</div>
