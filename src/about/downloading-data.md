---
title: Downloading The Data
layout: docs
description: An overview of the different formats that the source data is available in, including YAML, CSV and even a JSON API.
index_for_search: true
---
# Downloading The Data

**This data is made available under the Open Data Commons Attribution License: [http://opendatacommons.org/licenses/by/1.0/](http://opendatacommons.org/licenses/by/1.0/)**

For your convenience, this site provides the data for download in multiple formats. There are no restrictions on how you might use the data apart from an attribution (just so readers can know where the data was sourced from) and that you understand [the risk that the data might contain errors](/about/this-site/).

There is no requirement to tell me if you are using the data, but I hope you would share with me if you are doing something cool. And feedback is always welcome about ways to improve the data downloads!

## YAML Data

As mentioned in the [About This Data](/about/this-data) page, this data for this site is maintained as a series of YAML files which are processed and imported into a database which is used to generate the site. These files can be retrieved directly from the [Github repo](https://github.com/harrisj/doge_track/data), but for convenience the direct file downloads are below:

- [agencies.yaml](https://raw.githubusercontent.com/harrisj/doge_track/refs/heads/main/data/raw_data/agencies.yaml)
- [aliases.yaml](https://raw.githubusercontent.com/harrisj/doge_track/refs/heads/main/data/raw_data/aliases.yaml)
- [cases.yaml](https://raw.githubusercontent.com/harrisj/doge_track/refs/heads/main/data/raw_data/cases.yaml)
- [change_log.yaml](https://raw.githubusercontent.com/harrisj/doge_track/refs/heads/main/data/raw_data/change_log.yaml)
- [documents.yaml](https://raw.githubusercontent.com/harrisj/doge_track/refs/heads/main/data/raw_data/documents.yaml)
- [exec_orders.yaml](https://raw.githubusercontent.com/harrisj/doge_track/refs/heads/main/data/raw_data/exec_orders.yaml)
- [interagency.yaml](https://raw.githubusercontent.com/harrisj/doge_track/refs/heads/main/data/raw_data/interagency.yaml) (events that span agencies)
- [people.yaml](https://raw.githubusercontent.com/harrisj/doge_track/refs/heads/main/data/raw_data/people.yaml) (includes their positions at agencies)
- [publishers.yaml](https://raw.githubusercontent.com/harrisj/doge_track/refs/heads/main/data/raw_data/publishers.yaml)
- [questions.yaml](https://raw.githubusercontent.com/harrisj/doge_track/refs/heads/main/data/raw_data/questions.yaml)
- [roundups.yaml](https://raw.githubusercontent.com/harrisj/doge_track/refs/heads/main/data/raw_data/roundups.yaml) (DOGE listings from NYT, ProPublica, etc.)
- [sources.yaml](https://raw.githubusercontent.com/harrisj/doge_track/refs/heads/main/data/raw_data/sources.yaml)
- [systems.yaml](https://raw.githubusercontent.com/harrisj/doge_track/refs/heads/main/data/raw_data/systems.yaml) (includes system access records)

Please note that I might revise the structure of these YAML files significantly over time (the data will of course also change), as I add new features and functionality. If you are using the data to build your own things, it might make sense to download a copy or pin to a specific commit.

## SQL Dump

You can also download a full dump of the SQL database that is loaded from the YAML files:

- [DB SQL Dump (gzipped)](/downloads/dogetrack.sql.gz)

See the same note about the YAML files: the schema for this database may change over time. You should download a local file. You can also use the loading scripts within the repo to load the database (look for the commands in the Rakefile).

## CSV files

This site also includes several CSV representations of the data for your convenience:

- [agencies.csv](/csv/agencies.csv)
- [events.csv](/csv/events.csv)
- [people.csv](/csv/people.csv)
- [positions.csv](/csv/positions.csv)

## The JSON API

Finally, I have started to create a JSON API for the data. Since it is built using the same heavily-cached static generation techniques as the site, there is no need for rate-limiting or an API key.

Full Swagger documentation is available at [https://dogetrack.info/api/](/api/), but for now it includes the following endpoints:

- [/api/aliases.json](/api/aliases.json) - all the DOGE aliases
- [/api/agencies.json](/api/agencies.json) - a listing of all agencies with links to further details
- [/api/agencies/{slug}.json](/api/agencies/hhs.json) - information about a specific agency
- [/api/events.json](/api/events.json) - all of the events in the database
- [/api/people.json](/api/people.json) - a listing of all the people with links to further details
- [/api/people/{slug}.json](/api/people/luke-farritor.json) - information about a specific person
- [/api/systems.json](/api/systems.json) - all the systems I know about

More endpoints to be added in the future, but this is a start!
