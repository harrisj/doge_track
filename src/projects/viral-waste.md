---
title: Viral Waste
layout: docs
description: From the start, DOGE has claimed that its mission has involved fighting waste, fraud and abuse. This has resulted in many false alarms instead of actual fraud being found.
index_for_search: true
text_updated: 2025-06-21
---
{% import 'macros' %}
# Viral Waste

> The Times investigation found that Mr. Musk's Department of Government Efficiency first approached U.S.A.I.D. as a source of useful anecdotes of what it called "viral waste" - government spending that seemed foolish, and could be exploited to support the case for cuts.

From the start, DOGE has declared that its mission has included fighting fraud, and there are now multiple examples where DOGE teams have been directed to go into agencies and find something salacious that Elon Musk or Trump could tweet about as confirmation of the view that government is riddled with waste and fraud. Unfortunately, many of these examples turn out to be DOGE misunderstanding the data rather than finding a problem. 

You might notice that many of these examples are from the {%@ Atoms::AgencyLink "SSA", display: "Social Security Administration" %}, illustrating the vicious cycle that is kicked off by DOGE's conviction that waste and fraud are rampant. An initial accusation leads to a swarm of DOGE engineers descending on the agency. Those engineers then make further mistakes when trying to find other fraud. Which leads to more DOGE pressure on the agency, with experts sidelined and ignored when they attempt to correct the record. All of this leads to wasted work and deliberate falsehoods as DOGE makes claims without any investigation and then refuses to admit that it made a mistake.

{% project = Project['fraud'] %}

<div class="data-grid not-prose">
{%@ Grid::ProjectSystems project: project %}
{%@ Grid::Focused project: project %}
</div>
