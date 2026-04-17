---
title: Targeting for Elimination
layout: docs
index_for_search: true
description: Whenever the Trump Administration has decided to eliminate departments or entire agencies even, DOGE has often been heavily involved.
text_updated: 2025-06-21
---
# Targeting for Elimination

> We spent the weekend feeding USAID into the wood chipper. Could gone to some great parties. Did that instead. - Elon Musk

While [anti-personnel efforts](/projects/anti-personnel/) have cut a swath across the entire federal government, DOGE has also frequented targeted specific departments and even entire agencies for elimination. Perhaps the most prominent examples of this have been the destruction of {%@ Atoms::AgencyLink "USAID" %} and thwarted dismantling of {%@ Atoms::AgencyLink "CFPB" %}, but DOGE has also targeted numerous smaller [independent agencies](/agencies/independent) for destruction as well.

DOGE's methods have generally followed the same script:

1. If necessary, coordinate with the White House to fire agenecy directors or members of a supervisory board that might [prevent DOGE from being able to operate with impunity](/projects/impunity/) 
2. Then, arrange a meeting with agency leadership, under the pretense that you're authorized to perform [IT modernization](/projects/it-modernization/) and get them to sign a Memorandum of Understanding to detail DOGE staff into the agency.
3. Badger or force the IT staff to grant admin access for the DOGE team in systems that manage contracts, grants, system access and personnel. In some cases, DOGE teams have [relied upon allies in agency leadership](/people/agency-heads-cios/) to ensure this access.
4. If able to take over agency leadership, immediately place all employees on indefinite administrative leave and lock them out from accessing agency systems.
5. Use access to the contracts and grants systems to immediately [cancel contracts and rescind all grants](/projects/spending-control/).
6. Formally issue a massive Reduction in Force (RIF) notice to be executed as soon as feasible. Ensure nobody is taken off administrative leave before then.
7. Delete the website and gloat about it on X.

For more information on who has been involved with this work, see [The Wreckers](/people/wreckers).

{% project = Project['elimination'] %}

{% if project.govt_systems.any? %}
## System Access

{%@ 'tables/project_systems', systems: project.govt_systems %}
{% end %}

{% if project.events.any? %}
## Related Events

{%@ Table::Events project.events %}

{% end %}
