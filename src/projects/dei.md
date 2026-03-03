---
title: Targeting DEI
layout: docs
description: From the beginning, DOGE has been heavily involved in implementing changes, firing staff and terminating grants that it sees as supporting DEI or other measures of equity and social justice.
index_for_search: true
text_updated: 2025-06-21
---
# Targeting DEI 

From its very first day, the Trump Administration has had a profound contempt
for the concept of Diversity, Equity & Inclusion (DEI). This concept has
expanded to an aggressive hostility towards anything deemed too "woke,"
including LGBTQ rights (especially the inherent rights of transgender people),
protesting against Israel's occupation of Palestine or climate justice. DOGE has
supported these efforts as part of its intrusion into agencies, usually in one
of the following ways:

* Firing staff responsible for civil rights or other DEI-adjacent duties
* Eliminating content related to DEI topics from federal websites
* Canceling grants whose descriptions suggest they are DEI-related
* Canceling grants to entities who are seen as insubordinate to administration oversight of their material (often under the pretext of curbing antisemitism)
* Removing options from federal forms that reflect diversity. For instance, this might include changing a gender field to only reflect two choices.
* Curtailing studies or data collection that might illustrate racial or other disparities

Let you think they are just passively implementing administration guidance, DOGE
has sometimes bragged about making these changes on their X account. It's also
currently unclear if they were given the directive to eliminate grants based on
their descriptions or that guidance was developed internally by DOGE leadership.

{% project = Project['dei'] %}

{% if project.govt_systems.any? %}
## System Access

{%@ 'tables/project_systems', systems: project.govt_systems %}
{% end %}

{% if project.events.any? %}
## Related Events

{%@ 'tables/compact_event_timeline', events: project.events, agency_col: true, month_separator: true %}
{% end %}
