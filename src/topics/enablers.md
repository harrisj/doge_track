---
layout: page
title: Enablers
---
{% render "page_title", title: "The Enablers" %}

## Acting Leadership

{% acting = side.data.positions.select { |p| p.title =~ /acting/i %}
{{ acting | inspect }}

## Chief Information Officers

{% cios = site.data.positions.select {|p| p.title == "Chief Information Officer" } %}
{{ cios | inspect }}

