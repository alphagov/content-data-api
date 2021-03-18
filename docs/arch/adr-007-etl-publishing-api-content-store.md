# ADR 007: ETL to populate Content Items' dimension.

26-01-2018

## Context

As [per this Trello card][1], we want to populate the Content Items' dimension with the latest changes that result of editing content.
   
 
## Decision

Addressing the ETL process for Content Items this way:

1. The first time, we load all the content items via [publishing-api][3]. We retrieve all the content-ids and paths of all the content items that are live.
2. For each Content Item we will get the JSON from the [Content Store][2], and we will extract the attributes that we need to fulfil the immediate needs. We will also persist all the JSON to be able to extract other attributes in the future.
3. On a daily basis, we will be listening to [publishing-api][3] events, in the same way that [Rummager][4] or [Email Alert Service][5] do. Once we receive a change for the content item, we will automatically update the content items dimension with the new approach.

### Benefits:

1. This is more aligned with GOV.UK architecture.
1. This is very light and efficient. It also embrace simple code as the ETL process for Content Items is almost trivial.

## Status

Accepted.

[1]: https://trello.com/c/zqcU0x3s/28-3-content-items-find-source-for-content-items
[2]: http://github.com/alphagov/content-store
[3]: http://github.com/alphagov/publishing-api
[4]: http://github.com/alphagov/rummager
[5]: https://github.com/alphagov/email-alert-service
