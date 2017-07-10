# Content Performance Manager

`Provide content designers across all of government with the data and tooling they need to measure and improve ‘their’ GOV.UK content.`

This is an app that aggregates metrics from multiple sources to give easy view of content performance measurements.

### Setting up the application

The application contains a [setup script](./bin/setup) that will perform the
steps required to bootstrap the application.

```bash
$ ./bin/setup
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

### Importing themes

There are custom rake tasks for backing up and restoring themes:

```
bundle exec rake themes:backup
bundle exec rake themes:restore
```

We decided to check this data into git because themes are vital to the
application and they take a long time to set up.

These tasks will read/write a `themes.sql` file in the top-level directory.
Existing backups are in `backups/` and will need to be copied to use the rake
tasks, e.g. `cp backups/2017-06-11-themes.sql backups.sql`.

### Comparing themes against a CSV

Previously, inventories were exported as CSVs. There is a rake task that
compares one of these CSVs against the content items in a Theme and prints a
report. To run it:

```
bundle exec rake themes:compare[~/Downloads/transport.csv,Transport]
```

The first argument is the path to the CSV export. The second argument is the
name of the theme.

### API

* [Configuration](doc/api.md#set_up_api)
* [Samples](doc/api.md#samples)

### Deploying the application
* [Heroku](doc/deploying.md#heroku)
* [Integration](doc/deploying.md#integration)

### App development

* [GOVUK-LINT-RUBY](doc/govuk-lint.md)
* [Set up Google Analytics credentials in development](doc/google_analytics_setup.md)
