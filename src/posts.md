---
layout: page
title: Posts
---

<ul>
  {% collections.posts.resources.each do |post| %}
    <li>
      <a href="{{ post.relative_url }}">{{ post.data.title }}</a>
    </li>
  {% end %}
</ul>
