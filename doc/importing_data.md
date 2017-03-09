# Importing data

## Local environment

* To import all organisations:

```bash
$ rake import:all_organisations
```

* To import all taxonomies:

```bash
$ rake import:all_taxons
```

* To create or update the content items for an existing organisation:

```bash
$ rake import:content_items_by_organisation[{department-slug}]
```

* To import all content items for all known organisations:

```bash
$ rake import:all_content_items
```

* To get the number of page views for all content items belonging to an organisation:

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
