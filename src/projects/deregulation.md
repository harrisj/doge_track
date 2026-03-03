---
title: Regulatory Rollback
layout: docs
index_for_search: true
text_updated: 2025-06-21
---
# Regulatory Rollback

DOGE has also been supporting the general Project 2025/conservative project of
regulatory rollback. On Feb 19th, Trump signed an executive order [Ensuring
Lawful Governance and Implementing the President's "Department of Government
Efficiency" Deregulatory Initiative](/projects/exec-orders#eo-14219) (_yes, they
all have titles like this_) which declared that DOGE and the OMB should be
involved in reviewing every agency's regulations to revoke any that it deems
unnecessary for the agency's statutory duties. It also set the unrealistic
standard that 10 regulations must be revoked at agencies before they can add a
new one. 

DOGE's work here has involved the following threads:

- **Reviewing Regulations** As mentioned before, DOGE staff have sometimes been
  heavily involved in scrutinizing regulations, specifically ones that are seen
  to be violating the administration's [rules against DEI or acknowledging the
  impact of climate change](/projects/dei-lgbtq/). The actual process of
  revoking regulations is not something that DOGE can just do quickly and
  unilaterally; it requires following the [Administrative Procedure
  Act](https://en.wikipedia.org/wiki/Administrative_Procedure_Act), so DOGE's
  contribution there has been to suggest regulations to remove, often
  [identified by an AI process](/projects/it-modernization/).
- **Firing Regulators** in some cases, DOGE has been involved in eliminating
  positions or offices that are in charge of enforcing regulations. DOGE has
  also terminated contracts or grants that are used to support regulatory
  processes.
- **Stop-Work and Snitch Lines** If you can't remove a regulation, you can
  always suspend enforcement. Early on, DOGE set the template for this tactic at
  the {{ agency_link("CFPB") }}, with agency leadership setting up a special
  "snitch line" email address for the public to report if agency staff were
  still working.
- **Elimination** DOGE has frequently claimed that it's allowed to [eliminate
  agencies for not being statutorily compliant](/projects/elimination/), and
  many regulations are derived from statute. That said, DOGE still tried to
  eliminate the {{ agency_link("CFPB") }}, mainly because {{
  person_link("Russell Vought") }} harbored an intense dislike for it, and I
  would expect one goal of deregulation is to also eliminate more personnel and
  departments.

{% project = Project['deregulation'] %}

{% if project.govt_systems.any? %}
## System Access

{%@ 'tables/project_systems', systems: project.govt_systems %}
{% end %}

{% if project.events.any? %}
## Related Events

{%@ 'tables/compact_event_timeline', events: project.events, agency_col: true, month_separator: true %}
{% end %}
