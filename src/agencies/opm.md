---
agency_id: OPM
title: Office of Personnel Management
template_engine: serbea
---
{% blurb = capture do %}
Make a special agency page for OPM
{% end %}

{%@ "agency_page_generic", id: data.agency_id, blurb: blurb %}
