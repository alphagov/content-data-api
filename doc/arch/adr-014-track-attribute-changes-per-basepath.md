# Track attribute changes through time for basepaths

21-09-2018

## Context:

The Data Warehouse tracks changes to Content Items through time so, for
example, if we change the organisation attached to a Content Item, we should
know WHEN that change happened and WHAT changed.

Tracking changes not only applies to other entities associated to the Dimension
Items, but also to core attributes like the `title`, `description`,
`rendering-app`, or any other attribute. This is the foundation of our Data
Warehouse: track changes and track performance at the same time.

In GOV.UK we can identify a Content Item on a unique way by their `content_id`.

It is the combination of a `content_id` and a `locale` what makes a Content
Item unique. So on our first iteration of the DW, when we decided to use the
Content Item as the `grain`, hoping to be able to track all our changes by
`content_id`.

Shortly after we noticed that most of our metrics are not related to a Content
Item but the `base_path` of the item; the is due to some Content Items like
Guides or Travel Advice, has multiple `base_paths` and we need to track metrics
at that level (sub item). This was a business requirement driven by user
research.

So we decided to reduce the scope of the `grain` to the `base_path` of the
Content Item, which simplified and fulfilled our user needs. It was accepted by
the business that if the `base_path` changes, then we won't be able to track
the series backwards. We decided to postpone dealing with this issue when we
had more information about it.

As of today, we have learned more about our real needs for querying metrics.
Aggregating metrics through time for a Content Item with a base_path, need to
be done via its `content_id`, and there some edge cases to handle to be
accurate. Unfortunately, to address this issues, we need to make our queries
more complex, and the codebase is way more complicated to maintain and reason
about.

The underlying problem is that we don't have a way to track our grain
(base_path) through time because all the attributes can be changed, and
overcoming this limitation using `content_id` and `locales` it is just not
worth the effort.

In summary, we would need to provide an efficient way to:

Given a `base_path` in their latest version, select all the metrics through
time, regardless of the changes to the item. 

At the very end, what we are asking for is for a real unique identifier for the
item, because we actually don't have it, because the `content_id` is not
playing that role.

## Decision

Associate a unique identifier to each item that is tracked in the dimensions
item. 

Each `base_path`, which represents the grain of Data Warehouse, will have a
unique identifier that will never change. This ID will allow us to perform
queries through time in an efficient way, and also to be accurate with our
results.

On the same go, all the Contnet Items that share a locale will also be uniquely
referenced in the Data Warehouse.

### Note

We would not need to add this unique identifier if 

1. The sub-items for Content with multiple paths have a unique UID for each `base_path`. 
Unfortunately, to implement this feature we would need to modify each publishing 
application; which would impact our immediate delivery, so it needs a wider conversation.

2. All the content items that have different locales but same ID have a different
`content_id`.

## Consequences

It has a low impact in our codebase; we only need to generate it once (on
creation), then it will be cloned with each version, so at the very end, a few
lines of code with an important impact in our delivery.

~

