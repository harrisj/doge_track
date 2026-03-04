---
title: About This Data
layout: docs
description: An explanation of the iconography used throughout the site to compactly present categories of information.
index_for_search: true
text_updated: 2026-02-02
---
{% import 'macros' %}

# Symbols Used On This Site

In the hopes that it helps to better illustrate some of the themes within this data, this site relies heavily on the use of colorful icons provided by [Font Awesome](https://fontawesome.com/). This page offers some explanation of what these symbols mean.

## Position Moves
DOGE staff are constantly being moved around to various agencies or within organizations. To better illustrate that, I will use symbols to illustrate the type of action.

<ul class="list-none">
    <li><i class="fa-sharp fa-solid fa-arrow-left"></i> or <i class="fa-sharp fa-solid fa-arrow-right"></i> = detailing (an intra-agency position transfer)</li>
    <li><i class="fa-sharp fa-solid fa-arrows-left-right"></i> = transfer within an agency to a subsidiary agency (_e.g._, HHS to FDA)</li>
    <li><i class="fa-sharp fa-solid fa-person-to-door"></i> = appointment/hiring</li>
    <li><i class="fa-sharp fa-solid fa-arrow-up"></i> = promotion</li>
    <li><i class="fa-sharp fa-solid fa-arrow-down"></i> = demotion</li>
    <li><i class="fa-sharp fa-solid fa-person-shelter"></i> = conversion of temporary/time-limited role to a permanent one</li>
    <li><i class="fa-sharp fa-solid fa-left-from-bracket"></i> = exit from an organization/government (when known)</li>
</ul>

## Event Types
Events are also roughly categorized by type to better illustrate the type of event it is.

<ul class="list-none">
  {% %w(access action directory disruption interagency legal official onboard oversight offboard report sighting website).each do |type| %}
    <li>{{ render EventLabel.new(type, :icon) }} = {{ render EventLabel.new(type, :text) }}</li>
  {% end %}
</ul>

## Other Symbols

<ul class="list-none">
    <li><i class="fa-sharp fa-solid fa-receipt"></i> = sources</li>
    <li><i class="fa-sharp fa-solid fa-up-right-from-square"></i> = external link</li>
</ul>

## Terminology

Finally, a note on some government-specific terms that you might encounter in the tables listing details on DOGE staffing:

- **Detail** is the government term for when an employee (or **detailee**) of one agency goes to work at another agency
- **Excepted** means that the person was hired on an expedited and limited authority vs. the standard impartial and slow (aka **competitive**) hiring model. Usually, excepted appointments have limitations of a few years, but they allow for greater flexibility in hiring decisions and processes.
- A **Special Government Employee (SGE)** is someone hired on an extremely short-term basis (less than 180 days), but who, on the other hand,doesn't have to follow the standard government ethics rules.
- The **General Scale (GS)** is a series of 15 different pay levels (each with 10 steps) that standardize government pay for employees; there also is commonly a **locality adjustment** to reflect the cost of living in the employee's area.
- Above the GS scale, there is a **Special Executive Service (SES)** series of levels for limited numbers of high-ranking agency staff.
- Both excepted and SGE roles usually will have a **Not To Exceed (NTE)** date which is the maximum duration a person can be in that role.
- **Schedule C** is another exemption from the normal civil service hiring rules for political staff in policy roles who are subordinate to other appointees like agency heads.
