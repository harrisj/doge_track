---
title: Acting with Impunity
layout: docs
description: Once it enters an agency, DOGE wants to move fast and avoid being detected or constrained by any of these pesky rules or laws that govern normal federal employees. 
index_for_search: true
text_updated: 2025-06-21
---
# Acting With Impunity

DOGE is accustomed to acting with impunity. From the moment they enter an
agency, DOGE staff are usually fast-tracked to admin access on sensitive
systems. They get to bypass mandatory privacy and security training.
They are granted the ability to bypass normal system logs.

And when they encounter obstacles, they can appeal for help from [agency
leadership, who are often other DOGE staffers
themselves.](/people/agency-heads-cios/) Employees who flag their concerns or
refuse to comply are placed on administrative leave and fired. Entire
departments can be sidelined.


{% project = Project['impunity'] %}

{% if project.govt_systems.any? %}
## System Access

{%@ 'tables/project_systems', systems: project.govt_systems %}
{% end %}

{% if project.events.any? %}
## Related Events

{%@ 'tables/compact_event_timeline', events: project.events, agency_col: true, month_separator: true %}
{% end %}
