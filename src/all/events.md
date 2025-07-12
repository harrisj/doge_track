---
layout: page
template_engine: serbea
title: All Events
description: A comprehensive listing of all the events of DOGE staff on a single page
---
{%@ 'atoms/title', title: 'All The Events' %}

<p class="my-text">For the maximalists (and my debugging), here is a page with all of the events that happened in order.</p>

{%@ 'compact_event_timeline', events: site.data.events, agency_col: true, icon_col: true %}
