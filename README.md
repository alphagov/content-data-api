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

 ```bash
 $ rake import:organisation[{department-slug}]
 ```

 ### Deployment to Heroku

 1\. Setup the environment to deploy to Heroku

 ```bash
 $ rake heroku:prepare # Only need to be done once
 ````

 2\. Deploy to Heroku

 ```bash
 $ rake heroku:deploy
 ```

 To see updated (or data in new fields) data on heroku, you need to run:

 ```bash
 $ heroku rake import:organisation[{department-slug}]
 ```

 ### App development

 * [GOVUK-LINT-RUBY](doc/govuk-lint.md)
