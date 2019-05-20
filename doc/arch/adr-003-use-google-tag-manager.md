# ADR 003: Use Google Tag Manager

25-10-2017
 
## Context

Google Tag Manager (GTM) is an out-of-the-box analytics tagging package. It is designed to enable quick updates to web tracking.

The most important steps we have followed related to our development process are listed below:

1. Disable Custom HTML tags.
2. Set up multiple environments so that we can securely test changes in integration and staging.
3. All the data that is not directly configured via GTM with built-in tags [is manually published to the "Data Layer"][1].

To find all the details about our approach [GTM please read our GTM Wiki page][2].

## Decision

Use of Google Tag Manager (GTM) for CPM and the Audit Tool.

## Status

Accepted
  
[1]: https://github.com/alphagov/content-data-api/pull/322
[2]: https://gov-uk.atlassian.net/wiki/spaces/AC/pages/164954113/Google+Tag+Manager+GTM
