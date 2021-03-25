# Set up Google Analytics credentials in development

To be able to import data from Google Analytics, a few environment variables need to be set.

1) Create files `config/local_env.yml`

N.B. This file has been added to `.gitignore`, so you don't need to worry about accidentally checking it in.

`local_env.yml` is used to
* Create the environment variables required to connect to and query the Google API for Google Analytics
* Store your Google API credentials. They can either be downloaded from the [google developers console](https://console.developers.google.com/apis/credentials) or from another team member.

2) Add an entry to `config/local_env.yml` for each of the following:

* `GOOGLE_PRIVATE_KEY`
* `GOOGLE_CLIENT_EMAIL`
* `GOOGLE_ANALYTICS_GOVUK_VIEW_ID`

e.g.
```bash
GOOGLE_ANALYTICS_GOVUK_VIEW_ID: "1234567"
```

This will make "1234567" available as `ENV["GOOGLE_ANALYTICS_GOVUK_VIEW_ID"]`

`GOOGLE_ANALYTICS_GOVUK_VIEW_ID` is the view id on Google Analytics for `www.gov.uk`

See "Option Three" in [Rails Environment Variables](http://railsapps.github.io/rails-environment-variables.html) for more information

### Update facts table with GA metrics

To populate GA metrics for a given day, open a Rails console and run:

```
> GA.process(Date.today) 
```

It is recommended you disable logging to speed up the process:

```
Google::Apis.logger.level = Logger::ERROR
ActiveRecord::Base.logger = nil
```
