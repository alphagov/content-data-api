test
# Content Data API

A data warehouse that stores content and content metrics, and exposes this information via an API, to help content owners measure and improve content on GOV.UK.

Data is combined from multiple sources, including [Publishing API](https://github.com/alphagov/publishing-api), [Feedback](https://github.com/alphagov/feedback) and Google Analytics.

## Live examples

- [List all metrics](https://content-data-api.publishing.service.gov.uk/api/v1/metrics)
- [Last month of data for all organisations](https://content-data-api.publishing.service.gov.uk/content?date_range=last-month&search_term=&document_type=all&organisation_id=all)

## Nomenclature

- [Data warehouse](./docs/data-warehouse-what-and-why.md) - The database where we store all the metrics
- Fact - A record containing measurements/metrics
- Dimension - A characteristic that provides context for a fact (such as the time it was extracted, or the content item it belongs to)
- [Star schema](./docs/data-warehouse-schema.md) - The way we structure data in the data warehouse using fact and dimension tables
- ETL ([extract, transform, load](https://en.wikipedia.org/wiki/Extract,_transform,_load)) - How we get data into the data warehouse

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

To run the test suite:

```bash
bundle exec rake
```

## Further documentation

- [Importing production data](docs/import_production_data.md)
- [Running the ETL process locally](docs/google_analytics_setup.md)

## Licence

[MIT License](LICENCE)

[GOV.UK replication scripts]: https://docs.publishing.service.gov.uk/manual/replicate-app-data-locally.html
