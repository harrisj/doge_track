---
layout: docs
title: DOGE's Executive Orders
description: DOGE has been granted its sweeping powers through multiple executive orders issued by the Trump Administration from Day One.
---
{%@ 'title', title: 'Executive Orders' %}

From the very beginning, all of DOGE's influences and responsibilities have been defined through executive orders. These are directives issued by the President that are meant to apply to the Executive branch agencies. Notably, executive orders do not carry the same weight as laws that have passed both houses of Congress or agency regulations that have followed the process in the [Administrative Procedure Act](https://en.wikipedia.org/wiki/Administrative_Procedure_Act). In this sense, much of DOGE's mandate and power has rested on bluster and overreach in these executive orders, which is why the administration continues to lose legal challenges in the courts for DOGE's actions.

This page lists the executive orders that have been applicable to DOGE's actions.

{% site.data.executive_orders.each do |eo| %}
<table class="table table-xs sm:table-sm lg:table-md border-4">
<tbody>
  <tr>
  <th class="align-top w-2/12">Title</th>
  <td class="align-top w-10/12"><a class="link-hover" href="{{ eo.link }}">EO {{ eo.id }}: {{ eo.title }}</a></td>
  </tr>

  <tr>
  <th class="align-top w-2/12">Date</th>
  <td class="align-top w-10/12">{{ render EdtfFormat.new(eo.date) }}</td>
  </tr>

  {% if eo.directs_doge || eo.all_agencies %}
  <tr>
    <th class="align-top w-2/12">Directives</th>
    <td class="align-top w-10/12">{% if eo.directs_doge %}<span class="pr-1"><i class="fa-sharp fa-solid fa-square-check"></i> DOGE</span>{% end %} {% if eo.all_agencies %}<span class="pr-1"><i class="fa-sharp fa-solid fa-square-check"></i> All Agencies</span>{% end %}</td>
  </tr>
  {% end %}

  {% if eo.agency_ids.any? %}
  <tr>
    <th class="align-top w-2/12">Specified</th>
    <td class="align-top w-10/12">{{ eo.agency_ids | agency_links }}</td>
  </tr>
  {% end %}

  <tr>
  <th class="align-top w-2/12">Summary</th>
  <td class="align-top w-10/12">{{ eo.linkified_summary | md | strip_p }} <a class="link-hover" href="{{ eo.link }}">[full text]</a></td>
  </tr>
</tbody>
</table>

{% end %}
