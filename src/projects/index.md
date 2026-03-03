---
layout: docs
title: DOGE's Projects
description: Behind the chaos, it's possible to discern that DOGE has been working on several distinct projects across the federal government to reduce staff, slash costs and build a "god view" of government data.
index_for_search: true
text_updated: 2025-06-21
---
{% import 'macros' %}
{%@ 'atoms/title', title: "DOGE's Projects" %}

Now that we are several months into DOGE's regime, it's a little bit easier to see the deliberate goals behind the smash-and-grab antics. Much of the early media coverage focused on DOGE as if it were an independent entity and its [actions were attuned to whatever would benefit Elon](https://www.rollingstone.com/politics/politics-features/trump-elon-musk-doge-weaken-regulators-1235284085/). That is still true of course, but it's also now clear that DOGE has been the "boots on the ground" within agencies, there to enforce the political aims of the Trump administration. I personally found it useful to consider the executive branch as a triumvirate composed of {{ person_link("Elon Musk") }}, {{ person_link("Russell Vought") }} and Stephen Miller (whose wife, {{ person_link("Katie Miller") }} was in DOGE from the start). DOGE has embarked on the following major projects to enforce their aims:


{% Project.each do |project| %}
- [{{project.title}}]({{ project.path }}): {{ project.summary }}
{% end %}
