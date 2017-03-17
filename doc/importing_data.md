# Importing data

## Local environment

The application contains a number of `rake` tasks used to populate the database, these are listed below.
Currently when importing `organisations` and `content_items` the live `search-api` and `content-store` are used respectively.

The importing of taxonomies however uses the `publishing-api` therefore an additional step is required to run a local import (noted below).

**All organisations:**

```bash
$ rake import:all_organisations
```

**All taxonomies:**

**Note:** You will need to run the `publishing-api` via the [VM](https://github.com/alphagov/govuk-puppet/tree/master/development-vm) to import taxons locally else you will receive timeout errors.


```bash
$ rake import:all_taxons
```

**Create or update the content items for an existing organisation:**

```bash
$ rake import:content_items_by_organisation[{department-slug}]
```

**All content items for all known organisations:**

```bash
$ rake import:all_content_items
```

**Page views for all content items belonging to an organisation:**

```bash
$ rake import:number_of_views_by_organisation[{department-slug}]
```

## Jenkins

There is a Jenkins job, `Run rake task` that can be used to import data.

1) Select the `Run rake task` job

2) Select `Build with Parameters`

3) Set the following:
  * TARGET_APPLICATION: `content-performance-manager`
  * MACHINE_CLASS: `backend`
  * RAKE_TASK:
     * `import:all_organisations`
     * `import:all_taxons`
     * `import:content_items_by_organisation[{department-slug}]`
     * `import:all_content_items`
     * `import:number_of_views_by_organisation[{department-slug}]`
