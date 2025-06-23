---
title: Widespread Data Aggregation
layout: docs
---
{% import 'macros' %}
# The Panopticon

Of course, there is one big DOGE project that might be where they have been focusing most of their resources. The full scope of the project and even its name is unknown. It's also unclear if these are several different projects or one big thing. I would expect further details to emerge in time, but this is what we know now.

In early February, there were reports that DOGE had detailed up to 20 staffers within the {{ agency_link("ED", "Department of Education") }} and they were feeding large amounts of data from those systems into an AI hosted on Azure. There have been similar reports that DOGE was using an on-premises AI system at {{ agency_link("OPM") }} to process emails received from the Government-Wide Email System (GWES). There hasn't been any formal verification of these claims, but they seem to have been the precursors for a system that DOGE has been working on since March: an unnamed data lake that is aggregating data from {{ agency_link("DHS") }}, {{ agency_link("SSA", "Social Security") }} and {{ agency_link("HHS") }} including Medicaid data.

The goal, as _Wired Magazine_ put it, is to build a [master database to track and surveil immigrants](https://www.wired.com/story/doge-collecting-immigrant-data-surveil-track/). It's unclear how much development work DOGE has been doing for this project vs. what is provided already by the system, reportedly sold by Palantir. 

We also still don't have a lot of details on all the systems incorporated, but the following databases have likely been pulled into it:

{% systems = site.data.systems.select {|s| s.theme == 'panopticon'} || [] %}
{%@ 'project_systems_table', systems: systems %}