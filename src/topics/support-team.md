---
layout: 'page'
---
{% import 'macros' %}
{%@ "title", title: "The Support Team" %}

If we can think of the [Wreckers]({{% link "topics/wreckers.md" }}) as the offense for DOGE, there are a large number of staff that support their operations. The main group is at OPM

{% support_team = site.data.people.select { |c| c.category == 'support'}.sort_by(&:sort_date) %}
<table class="table is-size-5">
  <thead>
    <tr>
      <th>Name</th>
      <th>Age</th>
      <th>Agency</th>
      <th>Start Date</th>
      <th>Position</th>
    </tr>
  </thead>
  <tbody>
  {% support_team.each do | person|  %}
    {% pos = person.positions.find {|x| x.type == 'appointed'} %}
    {% if pos %}
    <tr>
      <td>{% person_link(person) %}</td>
      <td>{{ person.age }}</td>
      <td>{% agency_link(pos.agency_id) %}</td>
      <td>{% person.start_date %}</td>
      <td>{{ pos.title }}</td>
    </tr>
  {% end %}
  {% end %}
  </tbody>
</table>
