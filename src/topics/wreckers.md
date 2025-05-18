---
layout: 'page'
title: The Wreckers
template_engine: serbea
---
{%@ "title", title: "The Wreckers" %}

{% all_wreckers = site.data.people.select {|p| p.category == 'wrecker' } %}

From the start, DOGE has moved aggressively across the federal government to shutter agencies, cancel spending and seize data for itself. To do this, they have relied on a specific type of person that I call "Wreckers" – usually young and male, from a technical background, willing to do whatever it takes to get the job done quickly. Scratch the surface of any horror story about DOGE's conduct and you'll usually find a wrecker at the core.

## The DOGE Teams

In the January 20th Executive Order "[Establishing and Implementing the President's 'Department of Government Efficiency'](https://www.whitehouse.gov/presidential-actions/2025/01/establishing-and-implementing-the-presidents-department-of-government-efficiency/)" that established DOGE partially by renaming the US Digital Service, there was a section that described the formation and structure of DOGE teams that would operate at each federal agency

> (c) DOGE Teams. In consultation with USDS, each Agency Head shall establish within their respective Agencies a DOGE Team of at least four employees, which may include Special Government Employees, hired or assigned within thirty days of the date of this Order. Agency Heads shall select the DOGE Team members in consultation with the USDS Administrator. Each DOGE Team will typically include one DOGE Team Lead, one engineer, one human resources specialist, and one attorney. Agency Heads shall ensure that DOGE Team Leads coordinate their work with USDS and advise their respective Agency Heads on implementing the President's DOGE Agenda.

In this executive order, the DOGE teams were simply tasked with the vague goal of "IT Modernization" to make them seem like a continuation of the work that USDS had already been doing. However, what the DOGE Teams were actually there to do was to implement the "President's DOGE agenda." At first, this was left purposefully vague and undefined, but [a flurry of various executive orders]({% link "topics/executive-orders.md" %}) have made the goals of DOGE more clear.

## The Devil Is In The Details

Rather than hiring staff at specific agencies, DOGE has exploited a mechanism for sharing staff from one agency to another as the means to place its teams within multiple agencies quickly. Known as a "detail," this interagency transfer is formally defined through a legal document called a Memorandum of Understanding (MOU) which lays out the conditions of the detail assignment:

- The start date and not-to-exceed (NTE) date for the detailing arrangement
- The names or just what type of staffers are being detailed<
- Who will be managing them in the host agency
- If the host agency will be reimbursing the lending agency for their labor
- Signatories for both agencies agreeing to the detail arrangement

Detailing arrangements are relatively common in the government and can be a highly convenient way to reallocate resources or share knowledge across multiple agencies. They also are how the US Digital Service would embed its own staff within agencies, and DOGE simply appropriated that mechanism for its own ends. What DOGE has done that is unusual is to detail staff to many different agencies simultaneously, with staff sometimes juggling 5 or more simultaneous detailing assignments. For instance, sources described Gavin Kliger pulling 5 laptops out of his bag (one for each agency he was detailed to) when at an early meeting with the IRS. This is very much not normal, and it is likely that DOGE took this approach to both spread out its limited staff and cover its tracks.

There are still many details we don't know about DOGE's details (*sorry, I had to do it!*). Some of the relevant MOUs have been made public through FOIA or court filings, but many of the detailing arrangements listed below are inferred rather than verified. We also don't yet know if serial details were also done from the home base or if an agency could detail its detailees onwards to other agencies. Also, while many details were not reimbursed, there are some cases where the host agency would pay for the DOGE staffer for reasons that aren't necessarily clear. Team selection is also a black box. Of course, there will be answers to many of these questions in time, but for now we have to make sense the best we can of a deliberately murky situation.

## Home Bases

For reasons that aren't entirely clear, DOGE chose to distribute its staff across three different starting agencies as home bases rather than basing them entirely out of USDS/DOGE and detailing them from there. One possibility is that DOGE staff were involved with early work to seize control of centralized services and databases at both the GSA and OPM, so it made sense to start them there. One of the first moves of DOGE at both GSA and OPM was to create guarded and sealed enclaves where they could work and even live in, away from scrutiny. Perhaps, it simply was a matter of the DOGE headquarters at the Eisenhower Executive Office Building not being large enough to install sofas and bunks for all.

Since the beginning of March, DOGE has started to move some of its detailed staff to other agencies. For instance, Amy Gleason was appointed at HHS and Jordan Wick at CFPB on March 5th. This was a tactical move in response to TKTK

### USDS/DOGE

Most of the DOGE staff within the DOGE agency also called the US DOGE Service and often also referred to as the EOP (for Executive Office of the President) is leadership and support for activities across the government. However, a few of the early DOGE wreckers were hired in that agency, possibly through practices related to the USDS.

{% doge_wreckers = all_wreckers.select {|w| w.start_agency == "DOGE" } %}
{%@ "wrecker_table", wreckers: doge_wreckers %}

Since the beginning of March, DOGE has been moving staff to work within agencies themselves, a move at least in part designed to allow the government to evade expedited discovery in the [*AFL-CIO v. DOL*](https://storage.courtlistener.com/recap/gov.uscourts.dcd.277150/gov.uscourts.dcd.277150.51.1.pdf) case. For instance, Jordan Wick became an employee of the CFPB on March 4th, the same day that Amy Gleason and Brad Smith officially onboarded at HHS.

### Office of Personnel Management

Many of the early DOGE hires were formally appointed at the Office of Personnel Management. That

{% opm_wreckers = all_wreckers.select {|w| w.start_agency == "OPM" } %}
{%@ "wrecker_table", wreckers: opm_wreckers %}

## General Services Administration

{% gsa_wreckers = all_wreckers.select {|w| w.start_agency == "GSA" } %}
{%@ "wrecker_table", wreckers: gsa_wreckers %}

### Other Agencies

There are very few firm public details about the early days of DOGE, so there are some staff where I don't yet know how they started. These are all the other wreckers I am still trying to figure out details on.

{% other_wreckers = all_wreckers.select {|x| x.start_agency != "GSA" && x.start_agency != "OPM" && x.start_agency != "DOGE" } %}
<table class="table is-size-5">
  <thead>
    <tr>
      <th>Name</th>
      <th>Age</th>
      <th>Agency</th>
      <th>Start Date</th>
      <th>Background</th>
      <th>Detailed To</th>
    </tr>
  </thead>
  <tbody>
  {% other_wreckers.each do |person|  %}
    {% details = person.positions.select {|pos| (pos.type == "detailed" || pos.type == "internal") && pos.agency != person.start_agency } %}
    <tr>
      <td>{{ person_link(person.name) }}</td>
      <td>{{ person.age }}</td>
      <td>{{ agency_link(person.start_agency) }}</td>
      <td>{{ person.start_date }}</td>
      <td>{% if person.background %}{{ person.background | titleize }}{% end %}</td>
      <td>{{ details | agencies | agency_links }}</td>
    </tr>
  {% end %}
  </tbody>
</table>

## Raids On Other Agencies
