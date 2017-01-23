### Setting up the local environment

Create the test and development databases:

```bash
$ rake db:create
```

Run all migrations:

```bash
$ rake db:migrate
```

### Running the application
#### Using the GDS development VM

In the development VM, go to:

```bash
cd /var/govuk/development
```

Then run:

 ```bash
 bowl content-performance-manager
 ```

The application can be accessed from:

http://content-performance-manager.dev.gov.uk

#### From the local machine

The application can be started with:

```bash
$ ./startup.sh
```

In the browser navigate to: http://localhost:3206

### Running the tests
 ```bash
 $ bundle exec rake
 ```

### Importing data

* To import all organisations:

```bash
$ rake import:all_organisations
```

* To create or update the content items for an existing organisation:

```bash
$ rake import:content_items_by_organisation[{department-slug}]
```

* To get the number of page views for all content items belonging to an organisation:

```bash
$ rake import:number_of_views_by_organisation[{department-slug}]
```

### Deploying the application
* [Heroku](doc/deploying.md#heroku)
* [Integration](doc/deploying#integration)


### Set up Google Analytics credentials in development

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

### App development

* [GOVUK-LINT-RUBY](doc/govuk-lint.md)
