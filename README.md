# Content Performance Manager

A data warehouse that stores content and content metrics, to help content owners measure and improve content on GOV.UK.

This repository contains:
- Extract, transform, load (ETL) processes for populating the data warehouse
- An internal tool for exploring the data (AKA the sandbox)
- [An API that exposes metrics and content changes][api-doc]  (content-performance-api.publishing.service.gov.uk/#gov-uk-content-performance-api))

Data is combined from multiple sources, including the [publishing platform](https://github.com/alphagov/publishing-api), user analytics, [user feedback](https://github.com/alphagov/feedback).

## Live examples

- [List all metrics](https://content-performance-manager.publishing.service.gov.uk/api/v1/metrics)
- [Last month of data for all organisations](https://content-performance-manager.publishing.service.gov.uk/content?date_range=last-month&search_term=&document_type=all&organisation_id=all)

## Nomenclature

- **Data warehouse**: the database where we store all the metrics.
- **ETL**: [extract, transform, load](https://en.wikipedia.org/wiki/Extract,_transform,_load) - how we get data into the data warehouse.
- **Fact**: a record containing measurements/metrics
- **Dimension**: a characteristic that provides context for a fact (such as the time it was extracted, or the content item it belongs to)
- **Star schema**: The way we structure data in the data warehouse using fact and dimension tables

## Dependencies
- [GOV.UK Publishing API](https://github.com/alphagov/publishing-api)

## Setting up the application

### Using the GDS development VM

See the [getting started guide](https://docs.publishing.service.gov.uk/getting-started.html) for instructions about setting up and running your development VM.

In the development VM, go to:

```bash
cd /var/govuk/govuk-puppet/development-vm
bundle exec bowl content-performance-manager
 ```

The application can be accessed from:

http://content-performance-manager.dev.gov.uk

## Running the test suite
To run the test suite:
 ```bash
 $ bundle exec rake
 ```

 or you can also use [Guard](https://github.com/guard/guard), see [list commands](https://github.com/guard/guard/wiki/List-of-Guard-Commands)

 ```bash
 $ bundle exec guard
 ```

## Populating data
If you are a GOV.UK developer using the development VM, you can [run the replication script to populate the database](doc/import_production_data.md).

To run the ETL process locally, you need to  [set up Google Analytics credentials in development](doc/google_analytics_setup.md).




## Licence

[MIT License](LICENCE)

[docker]: https://www.docker.com/
[docker compose]: https://docs.docker.com/compose/overview/
[GOV.UK replication scripts]: https://docs.publishing.service.gov.uk/manual/replicate-app-data-locally.html
[api-doc]: /doc/api.md
