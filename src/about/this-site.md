---
layout: docs
title: About This Site
---
# About This Site

We are now several months into the second Trump presidency. It's been hard keeping track of all that is being damaged and lost within the federal government. Emboldened by Musk and the absence of oversight, the so-called "Department of Government Efficiency" (DOGE) has been rampaging through agencies to subvert their security, cancel contracts, fire staff and siphon up confidential data into large data warehouses. It's going to take years to both undo the damage and for any of them to face consequences.

As someone who has spent the past decade of my live in Civic Tech, this has been extremely demoralizing to watch. Not only are they destroying vital government services, they're undermining the idea that technology can serve the public good. I feel compelled to bear witness to this moment. But, I'm not particularly good at writing commentary. I'm no longer adjacent enough to journalism that I can report on what is happening. However, I do enjoy working with data and seeing what patterns will emerge over time from data collection and analysis.

## What You'll Find Here

This is the public-facing version of a <a href="https://github.com/harrisj/doge_track">deeper data-collection project that I have been working on since early February</a>. I have been evolving my data collection over time to track the following information about DOGE's activities:

- The names and placements of DOGE staff across the federal government
- Significant events at each agency
- Systems that have been accessed by DOGE and the possible risks
- Court cases that are linked to DOGE activities
- Possible identification of DOGE staff who have been masked in FOIA requests and legal documents
- Significant records related to hiring and detailing arrangements

## How It's Updated

This site uses a custom data pipeline of my own design that has evolved over time. I do all of my edits for the [source data in YAML plaintext files](https://github.com/harrisj/doge_track/tree/main/data) which are then automatically validated through scripts and loaded into a SQLite database. If you want to work with the data directly, pulling the YAML or loading the database is the easiest way to get raw data and you are welcome to use it.

Once I have loaded the data, other scripts will extract the data from the database into other YAML files that are used by my static site generator (_I know, I could have it read from the database, but I like have these files saved for debugging and version control_). When I push a version of the site upstream, these files are used to fill in data for the various pages on the site. This means that if I fix data in my source files, it should be reflected in the pages when I deploy it publicly.

For your convenience, I have included a "Last Updated" date in the footer for the site. I will update the entire site at a single time, so it does not apply to specific pages only.

## Reporting Errors and Ommissions

This website may be an act of journalism, but I am **not** a professional journalist. I will continue to strive to update the data and fix any errors that arise, but DOGE has made itself intentionally hard to track and some errors are almost certain to result. All of which is to say, **use this data at your own risk**. If you are using it as the basis for further investigations or legal arguments, please double-check my work (and let me know if you find any errors). I generally will link to original sources and have also started collecting significant documents.

Just remember, **this data is sometimes very messy.** DOGE has purposefully fought any attempts at transparency and has used staffing arrangements that are meant to deter tracking their movements. I often am working from second-hand news reports of rumored sightings. There are several ways in which I will indicate uncertainty and vagueness. For dates, I am using the [Extended Date Time Format](https://www.loc.gov/standards/datetime/) to indicate situations where dates are approximate (_2025-01-(23)~_) or even unknown (_2025-01-XX_). I will also sometimes flag errors with notes on tables.

## Contacting Me

To report errors or point out information that I might have missed, the best approach is probably to either email me at <a href="mailto:mail@jacobharr.is">mail@jacobharr.is</a> or on Signal at <strong>jacobharris.28</strong>. Please limit any tips or corrections to <strong>public information only</strong> (e.g., news reports, legal documents, official government reports). As I mentioned earlier, I am not a professional journalist. I do not have the time or ability to cross-check any confidential information, and I do not have the resources to protect leakers from investigation and retaliation. There are many other news sites that would accept leaked info and once they publish it, I will be able to pick it up.
