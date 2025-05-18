---
layout: page
template_engine: serbea
---
{%@ "title", title: "All The Events" %}

For the maximalists (and my debugging), here is a page with all of the events that happened in order.

{%@ 'event_timeline', events: site.data.events %}
