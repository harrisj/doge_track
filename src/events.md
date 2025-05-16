---
layout: page
---
{% render "page_title", title: "All The Events" %}

For the maximalists (and my debugging), here is a page with all of the events that happened in order.

{% assign events = site.data.events %}

{% render 'event_timeline', events: events, pages: site.data.pages %}
