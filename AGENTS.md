# DOGE TRACK — Project Agents & Commands

**Project:** DOGE TRACK — a Bridgetown static site tracking DOGE staff movements and government work patterns.  
**Architecture:** Ruby + Bridgetown + Sequel + SQLite backend, with YAML-driven data, a full set of domain models, and generated API/CSV/site assets.

---

## Quick Command Reference

| Command | Purpose | Notes |
|---------|----------|--------|
| `bin/bridgetown start` | Start the development server | Runs on port 4000 by default |
| `bin/bridgetown build` | Build the site for production | Outputs to `output/` |
| `bin/bridgetown console` | Drop into a Bridgetown console with DB loaded | Useful for debugging models |
| `bundle exec bt` | Run default deploy build | Equivalent to `rake deploy` |
| `bundle exec bt data:rebuild_db` | Clean, recreate DB, and repopulate from YAML | Runs full validation + populate + linkify |
| `bundle exec bt data:populate_db` | Load YAML raw data into `data/doge.db` | Must run after `data:create_db` |
| `bundle exec bt data:clean_db` | Delete `data/doge.db` | Safe to run anytime |
| `bundle exec bt data:create_db` | Create empty SQLite database with full schema | Calls `data/scripts/create_db.rb` |
| `bundle exec bt data:validate` | Validate all raw YAML files | Runs all YAML validators in order |
| `bundle exec bt data:validate:people_yaml` | Validate people + aliases YAML | Depends on `validate_aliases_yaml` |
| `bundle exec bt data:validate:systems_yaml` | Validate systems YAML | Depends on `validate_aliases_yaml` |
| `bundle exec bt generate:api_data` | Build `src/api/` JSON files from DB | Generates `agencies.json` + per-agency JSON |
| `bundle exec bt generate:csv` | Generate CSV files in `src/csv/` | Agencies, people, positions, events |
| `bundle exec bt generate:changed` | Build weekly changes summary in `src/_data/changes.yml` | Looks at git history, last 12 weeks |
| `bundle exec bt generate` | Run all generate tasks | Currently just CSV |
| `bundle exec bt frontend:build` | Build frontend assets via esbuild | Runs `yarn run esbuild` |
| `bundle exec bt frontend:dev` | Watch frontend assets during development | Runs `yarn run esbuild-dev` |
| `bundle exec bt test` | Run full test suite | Sets `BRIDGETOWN_ENV=test` |
| `bundle exec bt data/scripts/populate_db.rb` | Direct script: load YAML → DB | Same as `data:populate_db` |
| `bundle exec bt data/scripts/generate_api_json.rb` | Direct script: DB → API JSON | Same as `generate:api_data` |
| `bundle exec bt data/scripts/generate_csv_files.rb` | Direct script: DB → CSV files | Same as `generate:csv` |
| `bundle exec bt data/scripts/linkify_db.rb` | Direct script: add internal links to DB text fields | Called by `populate_db` |
| `bundle exec bt data/scripts/validate_people_yaml.rb` | Normalize + sort person YAML files | Ensures slugs, sorts positions, assigns IDs |
| `bundle exec bt data/scripts/validate_events_yaml.rb` | Normalize events YAML, re-route interagency events | Assigns IDs, validates sources, sorts dates |
| `yarn run esbuild` | Build frontend JS/CSS | Production build |
| `yarn run esbuild-dev` | Watch mode for frontend | Development |

---

## Data Pipeline Overview

```
raw YAML in data/raw_data/
        ↓ (data:validate + data:populate_db)
data/doge.db (SQLite, 12 tables, Sequel ORM)
        ↓ (linkify_db.rb)
DB fields linkified (blurb, text, evidence, summary)
        ↓ (generate:api_data, generate:csv, site pages)
src/api/*.json, src/csv/*.csv, output/
        ↓
Bridgetown static site pages
```

### Data Sources (YAML files)
- `data/raw_data/agencies/*.yaml` — individual agency files with embedded events
- `data/raw_data/people/*.yaml` — person records with positions
- `data/raw_data/aliases/*.yaml` — DOGE aliases (may have positions independently)
- `data/raw_data/cases.yaml` — court cases
- `data/raw_data/interagency.yaml` — events spanning multiple agencies
- `data/raw_data/systems.yaml` — government systems and access roles
- `data/raw_data/publishers.yaml` — news publishers
- `data/raw_data/sources.yaml` — source URLs
- `data/raw_data/projects.yaml` — project tracking
- `data/raw_data/entities.yaml` — general entities
- `data/raw_data/exec_orders.yaml` — executive orders
- `data/raw_data/questions.yaml` — Q&A records

All YAML files are processed through a series of `data/scripts/validate_*.rb` scripts before database population.

---

## Database Schema (SQLite, via `create_db.rb`)

The YAML scripts are the source of truth and are used to completely rebuild the
database on any load. Any alterations made to the database will not persist. The
primary purpose of the database is for building pages and doing analysis.

The database is at `data/doge.db` When possible, use the Sqlite MCP to query the database instead of using bash CLI commands.

### Core Tables
| Table | Key Columns | Notes |
|-------|-------------|--------|
| `agencies` | id, slug, short_name, parent_id, doge_base | Hierarchical (parent_id), slug unique |
| `people` | name (PK), slug, sort_name, association, age | association: confirmed/auxiliary |
| `positions` | id, type, category, agency_id, doge_alias_id, sort_date | Full federal position schema |
| `events` | id, type, date, sort_date, text | Event records linked to agencies/people |
| `cases` | case_no (PK), name, date_filed, status, link | |
| `govt_systems` | id, acronym, name, category, agency_id | DOGE-created systems tracked |
| `system_roles` | govt_system_id, doge_alias_id, agency_id | Access roles per system |
| `executive_orders` | id, title, date, summary, all_agencies, directs_doge | |
| `sources` | url (PK), pub_id, title, case_no | Foreign key to publishers |
| `publishers` | id, name, short_name, slug, hostname | |
| `projects` | id, title, summary, path, label_text, label_color | |
| `entities` | id, title, description, type, website | |
| `affiliations` | entity_id, name (FK to people), timeframe, role | |
| `doge_aliases` | id, agency_id, name, evidence | Aliases may or may not have associated people |

### PK & Linkage Gotchas
- **Some PKs are natural string keys, not surrogate IDs:** `people.name`, `cases.case_no`, and `sources.url` are PRIMARY KEYs. Joins between people ↔ positions ↔ events ↔ affiliations ↔ system_roles key off these strings (e.g., `positions.name` = person's full name; `events_people.name` = person's full name).
- `executive_orders.id` is the only **integer** PK (auto-increment); every other table uses an 8-char short-UUID string `id`.
- `positions` link to people via `positions.name` OR via `doge_alias_id` → `doge_aliases` (only 40 of 515 positions use an alias; 1 position has NULL `name`).
- `events_people` junction key is composite `UNIQUE (name, event_id)` with FK `name → people.name`.
- Required NOT NULL columns: `events` (`id, type, date, sort_date, text`), `positions` (`id, type, category, sort_date`).
- `people.association` defaults to `'confirmed'`; valid values: `confirmed`, `auxiliary`, `possible`.
- The DB is fully recreated from `data/raw_data` on every rebuild (`data:clean_db` + `data:create_db` + `data:populate_db`); models should treat it as read-only — manual DB edits never persist.

### Junction Tables
- `agencies_events`, `agencies_cases`, `agencies_executive_orders`
- `events_sources`, `events_people`, `events_projects`
- `positions_sources`, `positions_projects`, `doge_aliases_events`, `doge_aliases_sources`
- `affiliations_sources`, `sources_system_roles`, `govt_systems_projects`
- `events_projects`

All relationships are many-to-many via Sequel's `many_to_many` and `one_to_many` macros.

---

## Model Architecture (Ruby / Sequel)

Models live in `models/` and follow standard Sequel conventions:

- `Agency` — has children, positions, system_roles, cases, EO links; methods for `all_events`, `all_positions`, `all_agency_ids`, `page_url`
- `Person` — has positions; association defaults to "confirmed" if positions exist, else "auxiliary"
- `Position` — full federal position model with date fields, truth columns, series, etc.
- `Event` — text events linked to agencies, people, doge_aliases, sources, cases
- Each model uses `eager_graph` for efficient joins and `many_to_many` for association tables

The `populate_db.rb` script coordinates loading all YAML data and building relationships. It processes agencies first, then people (with position assignment), then aliases, cases, questions, exec orders, systems — all in dependency order.

---

## Important Notes & Gotchas

1. **YAML IDs are 8-char short UUIDs** — generated by `ShortUUID.shorten` when missing. Do not manually assign IDs; let the validation scripts handle it.

2. **EDTF dates** — All date fields in YAML use EDTF format (e.g., `2026-07-XX` or `2025-08-(08)~`). The `edtf` and `edtf-humanize` gems handle parsing. Do not use plain ISO dates unless they're unambiguous EDTF.

3. **Dates might not match** - this is an inherently messy dataset. There may be cases where we know specific dates for a person's departure from an agency or the government but not know when they ended a detail to another agency. Those dates will be kept null, even though we know an upper bound for the detail to end.

4. **Truth settings** - for dates and a few other fields, it is important to look at the associated `_truth` field (eg. `end_date_truth`). In order of declining confidence, its values can be `verified`, `self-reported`, `reported`, `inferred` and `guessed`.

4. **Interagency events** — Events with multiple agencies are stored in `interagency.yaml` and reassigned during population. The script separates them and only assigns to the interagency file if they truly span >1 agency.

5. **Person positions & aliases** — A person's YAML file may omit positions that are instead defined in an alias YAML. The `validate_people_yaml.rb` script merges alias positions back into the person record.

6. **DOGE base agencies** — The `doge_base` boolean on agencies flags which agencies are DOGE-controlled. Used for filtering in site generation.

7. **Linkified fields** — After `linkify_db.rb` runs, fields like `linkified_blurb`, `linkified_text`, `linkified_evidence`, `linkified_summary` contain HTML with internal anchor links. These are consumed by Bridgetown's site rendering.

8. **Rake task ordering matters** — `data:rebuild_db` runs `data:validate` first, then `data:clean_db`, then `data:create_db`, then `data:populate_db` (which calls `linkify_db.rb`). Do not skip validation if adding/editing YAML.

9. **`generate:changed` uses git history** — The script checks `git diff` for the last 12 weeks to determine what changed. It will not work correctly if git is not available or if the repo is shallow.

10. **API JSON generation** — `generate:api_data` outputs a flat `agencies.json` and one `agencies/<slug>.json` per agency. Each agency file includes its events with embedded agency/person/alias data.

11. **CSV generation** — `generate:csv` outputs 4 files: `agencies.csv`, `people.csv`, `positions.csv`, `events.csv`. Used by site data tables and for bulk analysis.

12. **`src/_data/changes.yml`** — Generated by `generate:changed`, consumed by site to show recent updates.

13. **Puma configuration** — `config/puma.rb` sets workers/threads based on `BRIDGETOWN_CONCURRENCY` and `BRIDGETOWN_MAX_THREADS`. Preload app is enabled.

14. **Bridgetown plugins** — Enabled: `bridgetown-sitemap`, `bridgetown-seo-tag`, `bridgetown-routes` (commented out), `nokolexbor`, `sanitize`, `edtf`, `sequel`, `shortuuid`, `edtf-humanize`, `kramdown`, `sanitize`.

15. **Frontend bundling** — Uses esbuild with custom plugins for glob imports, PostCSS, Sass. Config in `esbuild.config.js` and `esbuild.defaults.js`.

16. **Validation scripts are idempotent** — Running `validate_people_yaml.rb` multiple times is safe; it sorts positions and writes back consistently.

---

## Recommended Daily Workflow

```bash
# 1. Work on YAML data
vim data/raw_data/agencies/some-agency.yaml

# 2. Validate & fix errors
bundle exec rake data:validate:agencies_yaml
bundle exec rake data:validate:people_yaml

# 3. Populate DB
bundle exec rake data:populate_db

# 4. Build site assets
bundle exec rake generate:api_data
bundle exec rake generate:csv
bundle exec rake frontend:build

# 5. Preview
bin/bridgetown start
```

For bulk updates:
```bash
# Full rebuild from scratch
bundle exec rake data:rebuild_db
bundle exec rake generate
bin/bridgetown build
```

---

## File Structure Summary

```
data/
├── doge.db                 # SQLite DB (generated)
├── raw_data/              # Source YAML files
│   ├── agencies/          # One YAML per agency
│   ├── people/            # One YAML per person
│   ├── aliases/           # DOGE aliases
│   ├── cases.yaml
│   ├── interagency.yaml
│   ├── systems.yaml
│   ├── publishers.yaml
│   ├── sources.yaml
│   ├── projects.yaml
│   ├── entities.yaml
│   ├── exec_orders.yaml
│   ├── questions.yaml
│   ├── documents.yaml
│   └── schemas/           # JSON schemas for each type
└── scripts/                # Ruby scripts for data processing
    ├── populate_db.rb
    ├── generate_api_json.rb
    ├── generate_csv_files.rb
    ├── generate_changed.rb
    ├── generate_sources_pubs.rb
    ├── linkify_db.rb
    ├── validate_*.rb
    └── create_db.rb
models/                     # Sequel models (12 files)
src/
├── api/                   # Generated JSON API (from generate:api_data)
├── csv/                   # Generated CSV files (from generate:csv)
├── _data/                # YAML data for site (e.g., changes.yml)
└── ...                    # Liquid templates, components, etc.
config/                    # Bridgetown + Sequel config, Puma config
server/                    # Roda routes (if dynamic routing enabled)
bin/                       # Bridgetown binstubs (bridgetown, bt, bundle)
```
## Terminology
Finally, a note on some government-specific terms that you might encounter in the tables listing details on DOGE staffing:

- **Detail** is the government term for when an employee (or **detailee**) of one agency goes to work at another agency
- **Excepted** means that the person was hired on an expedited and limited authority vs. the standard impartial and slow (aka **competitive**) hiring model. Usually, excepted appointments have limitations of a few years, but they allow for greater flexibility in hiring decisions and processes.
- A **Special Government Employee (SGE)** is someone hired on an extremely short-term basis (less than 180 days), but who, on the other hand,doesn't have to follow the standard government ethics rules.
- The **General Scale (GS)** is a series of 15 different pay levels (each with 10 steps) that standardize government pay for employees; there also is commonly a **locality adjustment** to reflect the cost of living in the employee's area.
- Above the GS scale, there is a **Special Executive Service (SES)** series of levels for limited numbers of high-ranking agency staff.
- Both excepted and SGE roles usually will have a **Not To Exceed (NTE)** date which is the maximum duration a person can be in that role.
- **Schedule C** is another exemption from the normal civil service hiring rules for political staff in policy roles who are subordinate to other appointees like agency heads.
