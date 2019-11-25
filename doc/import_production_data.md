# Import Production Data

To import production data, follow the instructions for
[govuk-docker](https://github.com/alphagov/govuk-docker#how-to-replicate-data-locally)

## Using the `govuk data` tool

It's also possible to import data for the Content Performance Manager
using the experimental [`govuk data`][govuk-data-docs] tool.

[govuk-data-docs]: https://github.com/alphagov/govuk-guix/blob/master/doc/local-data.md

To see what data is available, run:

```
govuk data list content-data-api
```

To load the default extract, run:

```
govuk data load content-data-api
```
