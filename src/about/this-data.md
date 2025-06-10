---
title: About This Data
layout: docs
description: An overview of the technical infrastructure of this site. DOGE Track pulls in data from YAML and uses the Bridgetown tool to generate a static site. The front-end is implemented with Tailwind CSS and Daisy UI, and Font Awesome provides the iconography.
---
# About This Data

 This site is the latest iteration of a project that I started in early February (initially called [Trump Data](https://jacobharr.is/projects/trump-data.html)) where I was building out various datasets to track what was going on. This included data such as weekly unemployment statistics or whenever Trump visited one of his properties. I found myself sinking the most time into a project I called [IT Modernization](https://github.com/harrisj/trump_data/tree/main/it_modernization), where I was assembling data on DOGE's activities, as reported in various media outlets. This felt vital, since DOGE was doing everything in its power to both obscure the extent of its activities while also projecting an image of complete mastery and control.

 Because I am a developer, I decided to represent the data as [YAML](https://yaml.org/), since it offered a good balance between readability while also being data-parsable. I would then use this YAML file to create other YAML files, and I could go in and make edits as new data became available and it would be reflected in any derivative files.

Unfortunately, YAML is not particularly readable to non-developers. And my YAML could only be organized in one particular view but there was value in creating other pages. So, I decided it was time to use this data to generate a static website and the [doge_track project](https://github.com/harrisj/doge_track) was born.

## Data Collection

The heart of DOGE track are the [data files](https://github.com/harrisj/doge_track/tree/main/data). There is not unified feed of DOGE activities, so the only way I was going to be able to visualize it would be create my own dataset. Updating the data in here is the first step in changes being visible on the site.

### Raw YAML files

I have become enamored lately of editing data within a text data format (YAML, CSV, even JSON) when I have to track data over time. Many programmers might prefer to make their data edits in the database, but what I like about YAML for this project is:

- It is readable. I don't need to write SQL to update rows or use a GUI tool separate from my editor
- It is easily searchable. In the past, I would use the existing data in the YAML file to see if I had covered something or it needed to change.
- Adding new fields is very simple. I don't need to start with a DB schema migration, and sometimes I like to trial run a new field by making edits in the file and see how I feel.
- I can check changes into version control and rollback changes as well as see changes over a time period. This is the killer feature for me personally.

In the past, I have oscillated between having one gigantic YAML file to the other end of the pendulum (where I have a separate file for each of my major types). Currently I have a composite approach where some heavily associated elements are stored in a single file. The current files are located in the [raw_data](https://github.com/harrisj/doge_track/tree/main/data/raw_data) directory and they are:

- `agencies.yaml`: contains info about agencies and also events specific to that agency
- `aliases.yaml`: what I know about unidentified members of DOGE (usually redacted in court filings as things like OPM-3) including evidence if I feel like I can make an identification
- `cases.yaml`: some important legal cases that have affected DOGE operations
- `documents.yaml`: metadata and paths for documents I have cached locally
- `interagency.yaml`: for events that represent collaboration across multiple agencies
- `people.yaml`: information about the people each do. Each person also includes relevant positions representing time at specific agencies.
- `questions.yaml`: a place for me to record questions I have that can be linked to items in the generated site
- `roundups.yaml`: for recording the DOGE staff named by media outlets in special supplements (like the [NYT](https://www.nytimes.com/interactive/2025/02/27/us/politics/doge-staff-list.html) or [ProPublica](https://projects.propublica.org/elon-musk-doge-tracker/))
- `systems.yaml`: for tracking information both on federal IT systems and what access has been granted to them.

### Schema files and Validation

The promise of YAML is that it is machine-readable and can be hand-edited by people. The problem of YAML is that it humans will invariably make mistakes. To help catch errors, I employ several different tools as part of my editing process.


First, because YAML is really compatible with [JSON](https://www.json.org/json-en.html) and there are many software development tools that use YAML and/or JSON for their configurations, the [JSON Schema spec](https://json-schema.org/) is a tool that allows developers to define what are acceptable formats and values for their YAML files. I have defined a series of JSON schema counterparts for my YAML files (located in the [data schemas](https://github.com/harrisj/doge_track/tree/main/data/schemas) directory) and I use a plugin for my IDE that looks for a directive at the top of my YAML telling it which schema to use to validate the file contents (and display a list of problems if it finds them).


Taking this even further, I will also often extensively use JSON Schema's `enum` type to constrain valid inputs to specific set of values if it's important (for instance, what type of system access or how confident I feel about a date). These are located in a file named [valid_names.json](https://github.com/harrisj/doge_track/blob/main/data/schemas/valid_names.json) becaue my original use case was to define the acceptable values for agency names and the DOGE crew. This gives me a handy way to make sure I'm consistent both in properly spelling Aram Moghaddassi or sticking to only one variant when I need to identify people (just Pete Marocco and not Peter Marocco in some places). Eventually, these files might also be useful if I generate JSON for public consumption; for instance, I am thinking of creating a static API as well from this source data.

Beyond that, I have validation scripts that help me check for possible errors that might not be easy for schemas to identify (eg, if unique keys aren't). I also use these scripts in a somewhat clever way to prepare data for being imported into a database. To support joining across multiple tables, it's usually necessary for records to have a unique identifier called a primary key. Often when developers create records directly in the database, it can assign a new unique key (usually by auto-incrementing a number). But I don't do my editing in the database, I do it in my YAML files, and I might be making edits in different places. Tracking a primary key integer by hand would be impossible, but there is no rule that says primary keys must be integers for instance, only that they must be unique. So, as part of my validation process, my scripts read in the events or other records I want to check and see if they already have an `id` field set. If not, then the script generates a GUID and then truncates it down to 8 characters to use at the record ID (not as globally unique, but this isn't a huge dataset) and then assigns it to the record. After I have validated all the records, I then rewrite the file with the new data (and sort it as well). This means that every record has its own unique ID after the validation process runs.

Since this is a Ruby project, these scripts are invoked using Ruby's equivalent of make called rake. By calling `rake data:validate`, it'll check multiple files and I have even incorporated it as a pre-commit hook before I can commit files to the repo.

### The SQLite database

It is certainly possible to do everything through a combination of YAML files and data scripts (and indeed, I wind up doing more with YAML again later down the road), but sometimes it's highly useful to have data loaded into a relational database if you eend to do analysis or combine data in new ways. SQLite is a pretty awesome database you can run as a simple file, and it's perfect for small datasets like this one. The next phase of my data processing pipeline is to create a local database and load DOGE data into it. Since Sqlite is just a file, I find it easier to just rebuild the whole database from scratch. This is done by calling `rake data:rebuild_db` which deletes the old database and rebuild it.

Once I have the database loaded, I can use it for queries. To make things easier, I am using the [Sequel ORM](https://sequel.jeremyevans.net/), which provides a lightweight object model for databases. This lets me handle the associations between different tables (for instance, a person may have one or more positions in different agencies). It's a powerful way to work with the data - which is why I immediately use the database models to make more YAML files.

## Site Generation
This site is a mix of written content and tables built directly from the data. Between updates, there is no reason to change any of the pages, so there is no need to keep a server with a database running all the time. Instead, this is what they call a statically generated site. Whenever I make an alteration to the table, the code regenerates all the pages and then replaces them on a content delivery network.

There are multiple different tools in many languages for creating statically generated sites. I am using a different tool for [my personal site](https://jacobharr.is/), for instance. That site uses a tool called [Jekyll](https://jekyllrb.com/) and this site uses a new successor to it called [Bridgetown](https://bridgetownrb.com/). Both allow me to define templates that can pull in data. For instance, this is how I am displaying a row in the positions table:

{% raw %}
```ruby
{% dated_positions.sort_by(&:sort_date).each do |pos| %}
  <tr class="font-sans" id="{{ pos.id }}">
    <td class="align-top"><nobr>{{ position_move(pos) }}</nobr>  
    <div class="sm:hidden">{% if pos.start_date || pos.end_date %}{{ render EdtfFormat.new(pos.start_date, :compact, :none) }}{%if pos.end_date %}-{{ render EdtfFormat.new(pos.end_date, :compact) }}{% end %}{% end %}</div>
    </td>
    <td class="align-top hidden sm:table-cell">{% if pos.start_date || pos.end_date %}{{ render EdtfFormat.new(pos.start_date, :compact, :none) }}{%if pos.end_date %}-{{ render EdtfFormat.new(pos.end_date, :compact) }}{% end %}{% end %}</td>
    <td class="align-top">{% if pos.person %}{{ person_link(pos.person) }}{% elsif pos.doge_alias_id %}{{ alias_link(pos.doge_alias_id) }}{% end %}</td>
    <td class="align-top">{{ position_summary(pos) | md | strip_p }}</td>
  </tr>
{% end %}
```
{% endraw %}

There is a lot in here, and you don't need to understand it all or any of it. The only important thing to know is that I can define templates that check data and can spit out HTML based on what's in the data. One of the my favorite aspects of Jekyll and Bridgetown is that you can place arbitrary YAML files in a `_data` file and use that in your templates within the `site.data.*` namespace. For instance, [my resume is a large YAML file](https://github.com/harrisj/harrisj.github.io/blob/master/_data/cv.yml). This approach is what I needed for my new site.

But I have all my data in a database, not YAML files! What do I do?

### Creating Data files
Luckily, it's very easy to write some more code to pull data out of the database and create new files in the `_data` directory. The next step in my generation process is to run a script that connects to the database and writes out these files. Easy!

Now, this might seem silly to write YAML, read it into a DB and then write more YAML, but the second set of YAML files are more oriented towards the needs of my site's templates vs. the raw source date in the original. Of course, since Bridgetown is a Ruby app and remarkably flexible, I could instead put Ruby code in the `_data` directory to pull in the data, or I could even have it call the Sqlite3 database directly, but I found myself preferring the YAML files since it made it easier to debug errors that might arise during site generation.

### Creating the Frontend

If it wasn't already obvious, I consider myself more of a Backend engineer than a web designer. But, this project turned out to be a useful project for playing with some modern technologies. For this project, I learned about the following new technologies used in the front-end:

- [Tailwind CSS](https://tailwindcss.com/) and [DaisyUI](https://daisyui.com/)
- [Font Awesome](https://fontawesome.com/) for all of the cool icons
- [Render Cloud Application Platform](https://render.com/)

And that's it. As always, this project will remain open source, with [the code available on my Github](https://github.com/harrisj/doge_track).