# Importing data

## Local environment

The application contains a number of `rake` tasks used to populate the database, these are listed below.

The imports for `organisations`, `taxonomies` and `content_items` use the `publishing-api` therefore you will need to run the `publishing-api` via the [VM](https://github.com/alphagov/govuk-puppet/tree/master/development-vm) to import locally else you will receive timeout errors.

**All organisations:**

```bash
$ rake import:all_organisations
```

**All taxonomies:**

```bash
$ rake import:all_taxons
```

**All content items for all known document types:**

Note: see `config/document_types.yml` for the types currently processed.

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
     * `import:all_content_items`
     * `import:number_of_views_by_organisation[{department-slug}]`
