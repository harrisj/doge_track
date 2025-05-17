---
layout: page
title: Aliases
---
{% render "page_title", title: "Aliases" %}

In several examples, public documents obtained through FOIA and as exhibits in courts cases will obscure the identities of DOGE staffers. For instance, the testimony of Tiffany Flick and subsequent disclosures from the lawsuit against Social Security redact the identities of DOGE staffers as "Employee 1" etc. However, it is possible to figure out the identities of many of these aliases and link them to their real names if you happen to have a database of DOGE activities and documents and are able to correlate by evidence. When I am able to make such a positive identification, my system will then automatically link events and positions associated with the alias to the person as well. This page however is an overview of aliases.

{% assign aliases = site.data.aliases | sort: "id" | group_by: "agency_id" %}

{% for group in aliases %}
  {% assign agency_id = group.name %}
  {% assign agency = site.data.pages.agencies[agency_id] %}

## {{ agency.name }}

    {% for alias in group.items %}

<div class="card">
  <div class="card-content">
    <div>
      <p class="title is-4">{{ alias.id }}{% if alias.name %}: {% person_link alias.name %}{% endif %}</p>
    </div>
    <div class="content">
      {% if alias.evidence != blank %}
        {{ alias.evidence | markdownify }}
      {% endif %}
    </div>
  </div>
</div>

  {% endfor %}
{% endfor %}
