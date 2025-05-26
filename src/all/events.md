---
layout: page
template_engine: serbea
---
{%@ "title", title: "All The Events" %}

<p class="my-text-lg">For the maximalists (and my debugging), here is a page with all of the events that happened in order.</p>

{%@ 'event_timeline', events: site.data.events %}
