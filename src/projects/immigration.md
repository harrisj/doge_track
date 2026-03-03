---
title: Immigration Surveillance
description: DOGE's most ominous project has been building a large surveillance system at DHS that pools information about immigrants sourced from other agencies in dubious ways. This effort has also included efforts to pull in voting information of American citizens to support the administration's claims about voting fraud.
layout: docs
index_for_search: true
text_updated: 2025-06-21
---
{% import 'macros' %}
# Immigration Surveillance

In September 2025, reporting revealed that the tech company Palantir had won a
contract to build a tool called ImmigrationOS, which was designed to track
immigration and deportation. This was followed more recently by reports the
company is building another tool named ELITE to help ICE map the addresses of
people to arrest for deportation. We know these products exist because they were
federal procurements, which are public in nature. What we don't know as clearly
is all the work that DOGE has been doing to make these system viable.

These projects work by combining data sourced from federal data systems at the
IRS and Medicaid and Social Security Administration, as well as other data
purchased from data brokers to give a "god's eye" view of anybody who could be
targeted by ICE. This nightmare scenario is exactly what [The Privacy Act of
1974](https://en.wikipedia.org/wiki/Privacy_Act_of_1974) was passed to prevent.
But DOGE has generally operated as if the Privacy Act does not exist, and its
[missteps in identify fraud](/projects/fraud/) don't inspire confidence that
they won't make egregious errors in trying to combine information from various
systems that were not meant to be used this way. These errors will be compounded
as DOGE also tries to incorporate election data into its systems and push wider
use of SAVE as a verification tool.

There have been efforts to slow this unholy conglomeration in the courts. Agency
staff have protested the illegality of data sharing, usually to be suspended and
side-lined. Challenges in the courts have had some success, but have been
countered by the Supreme Court. Ultimately, it will be up to Congress to
eventually rein in these abuses, and by then they'll have harmed countless
lives.

{% project = Project['immigration'] %}

{% if project.govt_systems.any? %}
## System Access

{%@ 'tables/project_systems', systems: project.govt_systems %}
{% end %}

{% if project.events.any? %}
## Related Events

{%@ 'tables/compact_event_timeline', events: project.events, agency_col: true, month_separator: true %}
{% end %}
