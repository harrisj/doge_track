---
layout: 'page'
---
{% render "page_title", title: "The Support Team" %}

If we can think of the [Wreckers]({% link people/wreckers.md %}) as the offense for DOGE, there are a large number of staff that support their operations. The main group is at OPM

{% find support_team where site.data.people, category == 'support' %}
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
  {% assign support_iter = support_team | sort: "start_date"  %}
  {% for person in support_iter  %}
    {% find pos in person.positions, type == 'appointed' %}
    {% if pos != blank %}
    <tr>
      <td>{% person_link person.name %}</td>
      <td>{{ person.age }}</td>
      <td>{% agency_link pos.agency_id %}</td>
      <td>{% edtf person.start_date %}</td>
      <td>{{ pos.title }}</td>
    </tr>
  {% endif %}
  {% endfor %}
  </tbody>
</table>
