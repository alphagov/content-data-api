# Content Performance Manager (v0.1-alpha)

- Tagged with `v0.1-alpha` 
- This is the result of 3 sprints, 2 weeks each, run between November, December and January

> Note: Department and Organisations are uses indistinctly. 

## Goals

1. Find out what content belongs to an Organisation.
2. Display core attributes of a Content Item.
3. Pull metrics to evaluate how content is performing.

### Metrics

- Number of unique views in the last week.
- Last time a Content Item was updated (public_updated_at).
- Type of the Content Item (document_type).

## Information that belongs to a Department.

We list the Content Items that belong to an Organisation; this is a complementary filter to Taxonomies (Themes). 

Steps to retrieve content belonging to a Department:

1. [Query Search API for all the Content Items that belong to an Organisation](https://github.com/alphagov/content-performance-manager/blob/0a1faf2/app/services/content_items_service.rb#L5-L8). 
2. [Paginate through the Search API response yielding every Content Item](https://github.com/alphagov/content-performance-manager/blob/0a1faf2/app/services/content_items_service.rb#L8-L11).

### Next steps

1. Deploy the application in GOVUK infrastructure
2. Use [GDS adapters](https://github.com/alphagov/gds-api-adapters) to query SearchAPI and Content Store. This is the [Trello card][2].
2. Update the current association between Organisation and Content Items from `one-to-many` to a `many-to-many`. This is the [Trello card to accomplish this work][1]. We didn't do it in this iteration because we are focused on validating it with only one Department.

## Core attributes from the Content Store

We are **not going to replicate the information stored in the Content Store**, but we need a few attributes so a user can have  additional context for a particular URL:

Steps to retrieve additional attributes from a Content Item:

1. We use the `base_path` from the Search API and query the Content Store to retrieve: `title`, `description`, `public_updated_at`, `content_id` and `document_type`. 
2. Some of these attributes could also be pulled from the Search API, [but it feels more consistent to get them from the `source of truth` for Content Items: the Content Store](https://github.com/alphagov/content-performance-manager/blob/0a1faf2/app/services/content_items_service.rb#L17-L19).

### Next steps

1. Work out what is the best way to synchronise Content Store and the CPM. 
2. In a quick discussion with the Publishing Team, it seems sensible to have an endpoint in the Content Store that returns all the updates since a moment in time. This is the [Trello card to investigate][5] how to tackle this task.
3. It would be also very interesting to explore if it is a better approach to get all attributes from the content store online (do not store anything but the `id` and `base_path` and render the remainder attributes by querying the Content Store endpoint)

## Google Analytics (Unique Views)

* We are **not going to replicate Google Analytics for obvious reasons**, but we need to pull some GA metrics so we can describe better how the content is performing.

How to retrieve metrics from GA:

1. Use Google API for ruby.
2. We have a limit of 2000 requests per day, but as we are using batch requests, we are not exceeding our quota when pulling data for Public Health England (4000 content items)

We have decided to query [Google API][7] directly for the following reasons:

1. We could not find endpoints in the performance platform to retrieve GA stats for a particular URL. They seem to be more focused on aggregated data/stats. 
2. Performance platform kindly offered us to use their infrastructure (collectors) to retrieve GA stats, but we would prefer a more simple approach as our requirements are quite simple as of today.

### Next step

1. We still need to investigate what is the best size for our batch requests; both in Ruby side and in Google Analytics. There is a [Trello card][3] to address this task.
2. We would also need to add GA configuration to our app so we can track the usage of the application itself. This is the [Trello card][4].

# Content Performance Manager - Additional notes

## Last updated time more than 6 years ago

Some Content Items have a `public_updated_at` older than 6 years. Although this might look like a data issue, it could also be the case that a Content Item with a creation date of 5 years ago in the Content Store, and a `public_updated_at` of 25 years: sometimes we display content that was published 20 years ago and has not been updated since.

## State of Content Items

We are not considering state when listing Content Items for an Organisation. As a team, we still need to do more research about what happens when a Content Item is archived, created or drafted. 

We have not faced this piece of work yet in these three sprints because we wanted first to have an initial validation with our users of the tool we were building, and the state was not mandatory for this goal.

We have created [this Trello card][6] to investigate how the State is mapped in the Content Store for a Content Item.

## Data migration
We have built this version of the CPM while the Format migration was still in progress. 
The whole migration is close to completion, so having Content Items that have not been fully migrated is not affecting the validation of our first delivery.
Indeed, the existing metadata for the Content Items was enough for us because this information is not dependent of the full migration of the Content Item to the Publishing platform.

## Nested resources

1\. We are currently using nested resources to display the information of a Content Item. As of today, this is good enough, but it does not feel the way to go in the long run. We need to be able to display a ContentItem without knowing the organisation it belongs to.

```bash
rake routes
organisation_content_items GET  /organisations/:organisation_slug/content_items(.:format)
organisation_content_item GET  /organisations/:organisation_slug/content_items/:id(.:format)
organisations GET  /organisations(.:format)
```

2\. It also make sense to add Content Item slug to URL

## API 

1. CPM will expose an API so other apps can consume any information stored/calculated within the app
2. In this version (v1.0-alpha) we have not built it yet, but this is something planned for the end of any major delivery of the app.
3. To build the API it is recommended to use [Rails Serializers][9] although this is something that still needs to be decided.
4. We are also thinking of using [Swagger][10] to document the API (so we have a live API documentation of our app). Again, this is still to be decided. It might be worth contacting a Technical writer.

## UI: Admin template

Our application sits in the `management` group of apps within GOVUK. For this reason, we have added the suffix `manager`: see [RFC 63][8]

Some Notes about the UI:

1. It is deployed on the Backend layer of the GOVUK infrastructure, because it runs background processes, exposes an API and has its own database. It looks like a backend application, and not as a fronted app.
2. It will be available to Content Designers from any department in GOVUK
3. It has a similar layout to other Publishing tools that currently help Content Designers to publish their content.
4. If we decide to show to Citizens a subset of the information managed for the CPM, we just need to build a Frontend app that consumes the API of the CPM. This seems to be the approach followed by other apps within GOVUK.
## Infrastructure

The application is currently deployed in Heroku in this URL: https://content-performance-manager.herokuapp.com

## Moving the application forward. Open discussions

We need to flesh out more requirements for our tool so we can make more informed decisions about the architecture.

These would be interesting points to discuss:

- We are currently storing all metrics in our database, would it be the preferred way in the long run? What about storing them via publishing API? Does it make any sense?
- When we render all the content for an organisation, we are querying our database, not the Content Store. Would it be the preferred way for the long run?

We have started very simple: storing the data in our database and querying it and start exploring requirements. These are the main reasons:

1. Using a local database allow us to build quickly, and more importantly, it allows us to trash and rebuild even quicker.
2. Using Content Store to save metrics would entail a big amount of work, and we would need to have a better understanding of our requirements. 

[1]: https://trello.com/c/pLg019CM/109-3-create-a-many-to-many-association-between-contentitem-and-organisations
[2]: https://trello.com/c/4IpIenPQ/118-use-gds-adapters-to-integrate-with-search-api-and-content-store
[3]: https://trello.com/c/U01xbh0u/112-explore-pagination-in-cpm-and-google-analytics
[4]: https://trello.com/c/0giLFaZZ/114-google-analytics-universal-analytics-tag-needed-on-cpm-in-order-to-track-and-report-website-traffic-user-interaction-system-erro
[5]: https://trello.com/c/0KnA6vvi/119-spike-investigate-how-to-synchronise-the-content-store-content-items-with-our-app
[6]: https://trello.com/c/OGcWEfWO/120-spike-investigate-how-the-state-of-a-content-item-is-stored-in-the-content-store
[7]: https://github.com/google/google-api-ruby-client
[8]: https://gov-uk.atlassian.net/wiki/pages/viewpage.action?pageId=115081296
[9]: https://github.com/rails-api/active_model_serializers
[10]: https://github.com/swagger-api