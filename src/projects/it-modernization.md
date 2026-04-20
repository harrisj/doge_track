---
title: "IT Modernization"
layout: docs
description: For an organization claiming to do IT Modernization, DOGE has done shipped remarkably few products so far.
index_for_search: true
text_updated: 2025-06-21
---
{% import 'macros' %}
# "IT Modernization"

In the January 20th Executive Order "[Establishing and Implementing the
President's 'Department of Government
Efficiency'](/projects/exec-orders/#eo-14158)" that established DOGE partially
by renaming the US Digital Service, there was a section that described the
formation and structure of DOGE teams that would operate at each federal agency

> (c) DOGE Teams. In consultation with USDS, each Agency Head shall establish
> within their respective Agencies a DOGE Team of at least four employees, which
> may include Special Government Employees, hired or assigned within thirty days
> of the date of this Order. Agency Heads shall select the DOGE Team members in
> consultation with the USDS Administrator. Each DOGE Team will typically
> include one DOGE Team Lead, one engineer, one human resources specialist, and
> one attorney. Agency Heads shall ensure that DOGE Team Leads coordinate their
> work with USDS and advise their respective Agency Heads on implementing the
> President's DOGE Agenda.

Despite the description, DOGE initially used IT Modernization as a cover for its
activities to get a foot in the door, so that it could start its projects of
[spending control](/projects/spending-control/) or [eliminating
agencies](/projectes/elimination/).

However, DOGE has undertaken some IT modernization projects:

- **Government Wide Email Server (GWES)** the first project launched by DOGE was
  a system for emailing every federal employee. This was the underlying system
  for the Fork in the Road offer as well as the later Five Things email.
- **The DOGE Website** the DOGE website was launched in early January as a
  placeholder site. Over time, DOGE added more functionality that represented
  its perspective on what was important. First, they added an organizational
  chart, which was backed by a [poorly secured and easily hacked
  database](https://www.404media.co/anyone-can-push-updates-to-the-doge-gov-website-2/).
  Then, they added a Wall of Receipts for canceled contracts where the [math
  didn't add
  up](https://www.npr.org/2025/02/19/nx-s1-5302705/doge-overstates-savings-federal-contracts).
  Lately, they have expanded it to include [regulatory savings that are actually
  tallies of savings to businesses instead of the
  public](https://www.nytimes.com/2025/05/30/us/politics/doge-cuts-elon-musk-trump.html).
- **Automating RIFs** DOGE has also assisted in automating the layoff process for [reducing personnel](/projects/personnel/)
- **Digital Retirement** In late February, one of the cofounders of AirBnb named
  {%@ Atoms::PersonLink "Joe Gebbia" %} announced he had started on a project to fully
  digitize retirement processing at OPM and replace the existing paper-based
  processes. In May, they promoted it as a ["cornerstone of the DOGE
  effort"](https://www.opm.gov/news/opm-launches-historic-fully-online-retirement-application-system-across-federal-government.pdf).
  Unfortunately, it might also be a case of DOGE taking credit for [work that
  had already been in progress for
  years](https://fedscoop.com/doge-took-credit-for-his-work-now-an-opm-alum-fights-to-get-his-job-back/).
- **AI Assistants** DOGE has also rolled out or accelerated the use of AI
  assistants within several agencies. More importantly, it has been using AI to
  suggest [regulations for removal](/projects/deregulation).
- **Websites** Perhaps the most notable IT Modernization work lately by DOGE has
  been launching various websites, with most of them created by the newer {%@ Atoms::AgencyLink "NDS" %}.

{% project = Project['modernization'] %}

<div class="data-grid not-prose">
{%@ Grid::ProjectSystems project: project %}
{%@ Grid::Focused project: project %}
</div>
