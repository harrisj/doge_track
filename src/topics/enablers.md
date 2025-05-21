---
layout: page
title: Enablers
---
{%@ "title", title: "The Enablers" %}

## Acting Leadership

{% acting = site.data.positions.values.select { |p| p.title =~ /acting/i } %}
{{ acting | inspect }}

## Chief Information Officers

{% cios = site.data.positions.values.select {|p| p.title == "Chief Information Officer" } %}
{{ cios | inspect }}

