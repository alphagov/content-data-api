# Set up Google Analytics credentials in development

To import data from Google Analytics, you must set some environment variables.

Create the file `config/local_env.yml` if it does not already exist. This file will contain the environment variables for Google Analytics.

N.B. This file has been added to `.gitignore`, so you don't need to worry about accidentally checking it in.

## UA analytics

Add an entry to `config/local_env.yml` for each of the following:

* `GOOGLE_PRIVATE_KEY`
* `GOOGLE_CLIENT_EMAIL`
* `GOOGLE_ANALYTICS_GOVUK_VIEW_ID`

You can copy the credentials from the [google developers console](https://console.developers.google.com/apis/credentials) or from the AWS Secrets Manager under `content-data-api/google-analytics`.

e.g.
```bash
GOOGLE_ANALYTICS_GOVUK_VIEW_ID: "1234567"
```

This will make "1234567" available as `ENV["GOOGLE_ANALYTICS_GOVUK_VIEW_ID"]`

`GOOGLE_ANALYTICS_GOVUK_VIEW_ID` is the view id on Google Analytics for `www.gov.uk`

See "Option Three" in [Rails Environment Variables](http://railsapps.github.io/rails-environment-variables.html) for more information.

## GA4 analytics

Add an entry to `config/local_env.yml` for each of the following:

* `BIGQUERY_PROJECT`
* `BIGQUERY_CLIENT_EMAIL`
* `BIGQUERY_PRIVATE_KEY`

You can copy the credentials from the AWS Secrets Manager under `content-data-api/ga4`.

e.g.
```bash
BIGQUERY_PROJECT: "bigquery-project-name"
```

This will make "bigquery-project-name" available as `ENV["BIGQUERY_PROJECT"]`. These variables are used to authenticate and create the [BigQuery client](https://github.com/alphagov/content-data-api/blob/main/app/domain/etl/ga/bigquery.rb).

`BIGQUERY_PROJECT` is the project ID in the [Google Cloud console](https://console.cloud.google.com/).

See "Option Three" in [Rails Environment Variables](http://railsapps.github.io/rails-environment-variables.html) for more information

## Update facts table with GA metrics

To populate GA metrics for a given day, open a Rails console and run:

```
> GA.process(Date.today) 
```

It is recommended you disable logging to speed up the process:

```
Google::Apis.logger.level = Logger::ERROR
ActiveRecord::Base.logger = nil
```
