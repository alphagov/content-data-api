# API

** Important Note **

This is work in progess, and will change alonside the new requirements of the
application. As of now, it is only intended for evolving [Content Data
Admin](https://github.com/alphagov/content-data-admin), but in the long term,
once we have an stable version of the API, will be shareble across GOV.UK.

### All changes

Anytime you change what the API accepts as input or returns as output, you need to [update the OpenAPI spec and documentation](doc/api/README.md).

### Backwards incompatable changes

Currently the API is in alpha, so users should expect backwards incompatable changes without warning.

When the API is live, we will follow the [GDS API technical and data standards](https://www.gov.uk/guidance/gds-api-technical-and-data-standards#iterate-your-api)
- make backwards compatible changes where possible
- use a version number as part of the URL when making backwards incompatible changes
- make a new endpoint available for significant changes
- provide notices for deprecated endpoints
