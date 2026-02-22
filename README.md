# DOGE TRACK

This is the successor project to the "IT Modernization" project within [trump_data](https://github.com/trump_data/it_modernization), expanding on the data collection of the original to better track the movements of DOGE staff and spell out the way they work on a dedicated statically-generate website (coming soon!)

## Tell Me More

This is a [Bridgetown](https://bridgetownrb.com) project with the following special components:

- The `/data` directory is where the source data is kept and updated. Check this out if you want to use the raw data directly:
  - `raw_data` contains a collection of structured YAML files I will use to pull data
  - `schemas` are JSON Schemas that I use to validate the files while I am working on them
  - `scripts` are where I have scripts to process the YAML, load them into a SQLite DB and then bake out data files for the static site pages to use (as well as an API eventually)

  The basic flow is editing in YAML, loading into the DB and then using the DB to make other static files that are used by the Bridgetown pages to render out pages. This might seem more convoluted, but what I like about it is: I enjoy editing the data in a structured format that makes it easier to connect things without needing to load into a relational database first. And my data revisions are captured in source control.

  Note that this project includes a file of DB models that can be used with the Ruby `sequel` gem as its ORM.

  Plans for Future Work:
  - Building out an initial version of the site and launching it
    - Including some agency overviews (both specific pages and collections of smaller agencies)
    - Adding some specialized descriptions for things like aliases or the DOGE wrecker teams
    - Cleaning up some of the page generation logic
  - Adding visualizations like timelines to the more table-heavy pages
  - Filtering and reordering for event timelines
  - Government system pages (maybe grouped by function)
  - Maybe some sort of blog with updates (but the ship for that might have sailed)

## Want to Help?

There are several ways you can help! As you might have guessed, I'm not the greatest at web design so if you have better options, I'm all for it. I am currently using the following technologies on the project:

- Web Components (mostly in Liquid/HTMLe)
- Tailwind CSS
- SASS and esbuild

Nothing screams cutting edge about it, but I'm a one-person show doing this in my spare time, so "just okay" that ships is better than perfect that doesn't. If you have some bold ideas of how things should look, definitely get in touch.

Have you noticed an error? Do you have info on something that I don't? I'm always interested in things I might have missed. Note: I am **not** a professional journalist. I do not want to be responsible for safeguarding whistleblowers or chasing down tips for verification. So, I can only work with published info: either in the form of articles or legal testimony in court cases. I can't accept tips or leaks. Thank you.

Also, you are welcome to use this data, even if it's just to generate some leads. I do not retain any rights to it nor do I require any attribution. It is truly open data. While, I do make all attempts to be accurate and correct mistakes, **you use this data at your own risk** if there are errors in there. Please validate and verify on your own, if you are using this as the basis of any reporting or legal arguments. I do try to provide original sources whereever possible.
