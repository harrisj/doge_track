# frozen_string_literal: true

require_relative '../../data/scripts/models'

people_hash = {}

Person.each do |p|
  path = if p.page_slug
           if p.page_slug == 'self'
             "/people/#{p.slug}"
           elsif p.page_slug == 'none'
             'none'
           else
             p.page_slug
           end
         else
           "/people##{p.slug}"
         end

  people_hash[p.name] = { name: p.name, slug: p.slug, path: path, sort_name: p.sort_name }
end

agency_hash = {}

Agency.each do |a|
  path = if a.page_slug
           if a.page_slug == 'self'
             "/agencies/#{a.slug}"
           elsif a.page_slug == 'none'
             'none'
           else
             a.page_slug
           end
         else
           "/agencies##{a.slug}"
         end

  agency_hash[a.id] = { id: a.id, name: a.name, slug: a.slug, path: path }
end

{ people: people_hash, agencies: agency_hash }
