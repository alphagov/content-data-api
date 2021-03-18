# Content Data API

A data warehouse that stores content and content metrics, and exposes this information via an API, to help content owners measure and improve content on GOV.UK.

This repository contains:
- Extract, transform, load (ETL) processes for populating the data warehouse
- An internal tool for exploring the data (AKA the sandbox)
- [An API that exposes metrics and content changes][api-doc]

Data is combined from multiple sources, including the [publishing platform](https://github.com/alphagov/publishing-api), user analytics, [user feedback](https://github.com/alphagov/feedback).

## Introduction ##

- [What is a data warehouse and its role in GOV.UK][data-warehouse-what-why]
- [Database schema: star schema][data-warehouse-schema]

## Live examples

- [List all metrics](https://content-data-api.publishing.service.gov.uk/api/v1/metrics)
- [Last month of data for all organisations](https://content-data-api.publishing.service.gov.uk/content?date_range=last-month&search_term=&document_type=all&organisation_id=all)

## Nomenclature

- **Data warehouse**: the database where we store all the metrics.
- **ETL**: [extract, transform, load](https://en.wikipedia.org/wiki/Extract,_transform,_load) - how we get data into the data warehouse.
- **Fact**: a record containing measurements/metrics
- **Dimension**: a characteristic that provides context for a fact (such as the time it was extracted, or the content item it belongs to)
- **Star schema**: The way we structure data in the data warehouse using fact and dimension tables

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

To run the test suite:

```bash
bundle exec rake
```

## Populating data

If you are a GOV.UK developer using the development VM, you can [run the replication script to populate the database](doc/import_production_data.md).

### Run ETL processes locally

- To run the ETL process locally, you need to  [set up Google Analytics credentials in development](doc/google_analytics_setup.md).

## Licence

[MIT License](LICENCE)

[GOV.UK replication scripts]: https://docs.publishing.service.gov.uk/manual/replicate-app-data-locally.html
[api-doc]: /doc/api
[data-warehouse-what-why]: doc/data-warehouse-what-and-why.md
[data-warehouse-schema]: doc/data-warehouse-schema.md
