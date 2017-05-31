# Content Performance Manager

`Provide content designers across all of government with the data and tooling they need to measure and improve ‘their’ GOV.UK content.`

This is an app that aggregates metrics from multiple sources to give easy view of content performance measurements.

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

See the [getting started guide](https://docs.publishing.service.gov.uk/getting-started.html) for instructions about setting up and running your development VM.

In the development VM, go to:

```bash
cd /var/govuk/govuk-puppet/development-vm
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

 or you can also use [Guard](https://github.com/guard/guard), see [list commands](https://github.com/guard/guard/wiki/List-of-Guard-Commands)

 ```bash
 $ bundle exec guard
 ```

### Importing data

* [On the local environment](doc/importing_data.md#Local_environment)
* [On GOV.UK environments](doc/importing_data.md#jenkins)

### API

* [Configuration](doc/api.md#set_up_api)
* [Samples](doc/api.md#samples)

### Deploying the application
* [Heroku](doc/deploying.md#heroku)
* [Integration](doc/deploying.md#integration)

### App development

* [GOVUK-LINT-RUBY](doc/govuk-lint.md)
* [Set up Google Analytics credentials in development](doc/google_analytics_setup.md)
