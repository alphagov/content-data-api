# Content quality metrics in PAAS

### Getting set up with PAAS

1.[Create a PAAS account](https://docs.cloud.service.gov.uk/get_started.html#get-an-account)
2.[Install the Cloud Foundry CLI](https://docs.cloud.service.gov.uk/get_started.html#set-up-command-line)

### How to update the app

To redeploy the app simply run `cf push govuk-content-quality-metrics`. This will push live any changes that you have made.

### How to stop/start the app

To start the app run `cf start govuk-content-quality-metrics`.

To stop it run `cf stop govuk-content-quality-metrics`.

### Errors

The Content Performance Manager will raise errors in Sentry if the content quality metrics service is down.

Checking the app logs may be helpful to debug issues. You can see the logs by running `cf logs govuk-content-quality-metrics`

To test it out for yourself make a POST query to `https://govuk-content-quality-metrics.cloudapps.digital/metrics`, set the header `Content-Type:application/json` with the body `"content": "insert any content you like here preferably with some spelllling mistakes."`.
