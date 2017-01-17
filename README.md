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

The application can be started with:

```bash
$ ./startup.sh
```

In the browser navigate to:
 `http://localhost:3333`

 or `http://10.1.1.254:3333` if running from the GOV.UK Dev VM.

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

### Deployment to Heroku

1\. Setup the environment to deploy to Heroku

```bash
$ rake heroku:prepare # Only need to be done once
````

2\. Deploy to Heroku

Try one of the following methods:

##### Use the deploy script
```bash
$ rake heroku:deploy
```

##### Use the heroku deploy commands
```bash
$ git push heroku master
```

followed by:

```bash
$ heroku rake db:migrate
```

To see updated (or data in new fields) data on heroku, you need to run all of the import tasks:

```bash
$ heroku rake import:all_organisations
$ heroku rake import:content_items_by_organisation[{department-slug}]
$ heroku rake import:number_of_views_by_organisation[{department-slug}]
```

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
