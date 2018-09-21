# Store Content Item JSON that makes the dimensions grow

20-09-2018

## Context:

Each Content Item is defined by a JSON document that includes all the metadata,
the links and the content details. The
[links](https://github.com/alphagov/govuk-content-schemas/blob/45acb62/examples/news_article/frontend/news_article.json#L11-L57) include
information about organisations, policies, taxonomies, and details including the
actual content of the page, the attachments, and other necessary details like
title, description, publishing-app, rendering app, etc.

In the Data Warehouse, we started storing the Event with the JSON document, but
we decided to remove it because our database was growing too quickly. Later on,
we found out that we had a bug in our code because we were not filtering
Publishing-API events correctly. Some days we had more than 4 million events,
and each one of them implied a new version of a Content Item with no real
changes.

As of today (September 2018), the Content Items dimension is growing very
slowly, as it only tracks changes related to content updates. The current pace
of growth is around 600-800 rows per day, which is very small for a Data
Warehouse.

## Decision

Store the entire JSON document of the Content Items that grow the Items
dimension, which is the same as storing all the information that we currently
have about a Dimension Item.

### Benefits (storing all the attributes about a Content Item)

1. Storing the JSON document (in `jsonb` format) enable a quick exploration of
new features because the data is easily accessible with JSON queries (supported
natively by PostgreSQL).
2. It prevents long migrations when exploring new features because all the data
is immediately available.
3. It prevents the star-schema known issues with many to many associations in
Data Warehouses, as all the joins need to be additive. Not having the JSON
document implies that we need to look for more costly ways (when it comes to
development) to map many to many associations.

### Other foundations

1. The Data Warehouse tracks changes for content items. Item updates are
critical to the Data Warehouse, and they are the foundation for quick progress
on our findings and user research process. Tracking all changes to our Content
Items is directly related with what a Data Warehouse does for our domain.
2. Understanding the relationship between content updates and performance is
vital to be able to manage content at scale;  easy ways to model queries about
any content attribute through time is essential because we are discovering new
user needs on a daily basis.
3. The Data Warehouse tracks changes by growing the Items dimensions; changes to
Taxons or Policies could have an impact on performance, and our team (and
performance analysts) are working to find those patterns.  If we don't have all
the content available, the discovery process will be very tedious, as we would
need to run migrations to populate the content.
4. As of now, we don't know what content changes impact on performance; finding
out those changes are part of the lifecycle of the Data Warehouse and our
mission.
5. If we don't provide an easy way to recalculate our data backwards or to pull
in new data, it will impact our delivery pace. Having the JSON document as part
of the dimension item simplifies our work.
6. Storing the JSON document has a low impact in storage because of the
slow-growing dimension nature of the Content Items. The costs of storage are
several levels of magnitude smaller than the cost of development, so it seems
sensible to make the development process faster.
7. Storing the JSON document allows the team to explore features quickly without
custom developments or long migrations. Not saving the JSON document forces the
team to create a mechanism to retrieve events by demand, and think about the
management of large sets of events through the years. The Data Warehouse cares
about a small subset of events (only those that carry out meaningful changes).
8. Storing the JSON document allow the dev team to easily recalculate any field
if we have bugs in the codebase. For example, if parsing content has bugs, as of
now, we have no way to fix and reprocess the content (which is a product issue).

### Cons (storing all the attributes about a Content Item)

1. Storage: we will need more storage. As per previous calculations, it seems to
be a between 10MB and 20MB per day.
2. Risk of growing too quickly the database, although this is currently
mitigated because of our improved monitoring.
