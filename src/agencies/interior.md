---
agency_id: DOI
title: Department of the Interior
template_engine: serbea
---
{% blurb = capture do %}
TKTK
{% end %}

{%@ "agency_page_generic", id: data.agency_id, blurb: blurb %}
