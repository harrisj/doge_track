---
title: About This Data
layout: docs
description: An explanation of the symbols used throughout the site
---
{% import 'macros' %}
# Symbols Used On This Site

In the hopes that it helps to better illustrate some of the themes within this data (and because I can't really afford stock art or licensed photos), this site relies heavily on the use of colorful icons provided by [Font Awesome](https://fontawesome.com/).

## People Types


## Event Types

<table class="table table-xs sm:table-sm md:table-md table-zebra max-w-auto">
  <thead>
    <tr>
      <th></th>
      <th>Meaning</th>
    </tr>
  </thead>
  <tbody>
    {% %w(access action directory disruption interagency legal official onboard oversight offboard report sighting).each do |type| %}
    <tr>
      <td><i class="fa-sharp fa-solid {{ event_icon(type) }}"></i></td>
      <td>{{ event_title(type) }}</td>
    </tr>
    {% end %}
  </tbody>
</table>

## Other Symbols
