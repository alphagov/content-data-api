# The need for a Data Warehouse

This document is not an in-depth explanation of what is data warehouse but an
explanation of the reasons behind building it. There are many online resources
and books about Data Warehouses if you want to get further information about
this matter.

To understand the foundation for the Data Warehouse, let's start with the `long
term vision` that guided our work.

##  Long term vision

```
Give departments the data they need, at the point they need it so that they can
manage their GOV.UK content at scale over time.
```

Let's explore in detail:

## Give departments the data they need

Departments manage content daily. They publish, update and archive content as
part of their daily work; as of today, Content Designers don't have a single
place to get metrics about how their content is performing. This information is
beneficial to make informed decisions about their next steps.

As per user research, Content Designers would benefit from having two types of
metrics.

* Metrics about **content performance**:

```
Metrics that define how content behaves when it interacts with GOV.UK users. For
example, the number of visits, the number of searches within the page, the
number of feedback comments that a page is receiving, or the overall
satisfaction with a particular page.
```

These metrics are tracked daily.

* Metrics about **untent quality**:

These metrics are tracked/updated on each new version.

```
Metrics that define core characteristics of content: the reading score, use of
passive voice, guidelines compliance, number of paragraphs, words, complex sentences,...
```

## At scale and over time

`At scale` and `over time` key principles for the Data Warehouse, because
Content Designers are interested in:

1. Metrics for each content item that is or have been live in GOV.UK (around
   550K)
2. Trends of each of the metrics **over time**

To explain in detail why **over time** is important, let us explore three simple
examples.

### Example 1: Number of Content Items published by an organization

Departments are content owners; this means that they are responsible for
publishing, updating and archiving/retiring their content daily.

Diligent management of content implies a steady pace of updates and publications
while keeping the total number of content items in a sensible number.

For example, if an organization is publishing at a very high rate for an
extended period, it could be a signal that they need to improve the way they
archive or retire existing content.

To get these insights about content publication we can't focus on metrics for a
single day, we need to understand how those metrics evolved through time; we
need to explore metrics **over time**.

In the following example, we can see how metrics through time would help in this
scenario:

* **Content Items published by an organization in one day**

We have two organizations: `A` and `B`. In the last day, `Organisation A` has
`550` live Content Items and `Organisation B` has `400`.

With this information, it is not easy to say if any of those organization are
not doing good management of their content because we only have a metric on a
particular day of the year.

![without metrics over time][figure-1-no-trends]

* **Content Items published by an organization over time***

If we track the number of content items **over time**, then we noticed that
`Organisation A` is decreasing the number of Content Items daily, and
`Organisation B` is creating too many content items in the last year.

`organization b` would need to take action to improve the way they manage
content over time (can make an informed decision based on data about the way
they manage content)

![with metrics over time][figure-2-with-trends]

### Example 2: Enforcing good practices

Data is not only to help departments to manage their content over time; it can
also help to provide evidence about best practices and guidelines compliance.

For example, we discourage Departments from publishing content in PDF format.
There are many reasons for it, but having some metrics to prove it would shorten
the distance between the GOV.UK Guidelines and Department practices when
publishing content.

In the following example, we can see how there is a relationship between the
number of PDFs published by `Organisation A` and the `satisfaction score`.

![enforcing good practices][figure-3-comparisons]

### Example 3: Predictions

In our domain, as per the nature of the information that we share in GOV.UK ,
some user interactions follow seasonal patterns. If on a particular week or
month of the year a set of pages receive a spike on the number of visits, it is
very likely that the following year, on the same period, those pages will
receive at least, a similar number of visits.

Let's explore the following example: as per previous year (spike of visits in
June), `Organisation A` expects a spike in page views for a content item, so
they might consider reviewing in advance the content, so it is accurate and up
to date.

![predictions][figure-4-predictions]

# Why a Data Warehouse

Now that we have a better understanding of the needs behind tracking metrics at
scale and through time let's explore why we have chosen a Data Warehouse as the
underlying technology to support this functionality.

## Overview

Considering then user needs, and the long term vision, it seems that what we
need is:

```
A way to track daily snapshots of performance metrics, from multiple sources, of
all our content over time, so we can analyze it to make informed decisions about
content.
```

If we look into the Wikipedia definition of a Data Warehouse:

```
A central repository of integrated data from one or more disparate sources, that
stores current and historical data in one single place that is used for creating
analytical reports for workers throughout the enterprise.
```

And, if we replace:

source|replaced -------------------------------|-------------------------- one
or more disparate sources | Feedex, Google Analytics workers | Content Designers
the enterprise | All GOV.UK organizations

We get:

```text
A central repository of integrated data from Feedex, Google Analytics, PAAS...,
that stores current and historical data in one single place that is used for
creating analytical reports for Content Designers throughout all GOV.UK
organizations.
```

So, it seems that from a definition / formal perspective, it fits in what we
need to track metrics through time.

## Track content changes over time for Content Items

We not only need to track metrics about how content is performing through time,
but we also need to monitor the content attributes, so we understand the
relationship between content and performance changes through time.

Say, for example, that a content item was created and published three years ago.
To get a good understanding of how the content changes are related to their
performance, we would need to:

1. Track each change to the Content Item through the three years
2. Update the content metrics each time a new version is created
3. Link the performance metrics to each one of the versions of the Content Item.

Tracking the history of each content item is key to understand the relationship
between content and performance.

## A new application for GOV.UK?

With this context, we decided to build a new application for GOV.UK, a Data
Warehouse that will track content and performance changes through time and that
will enable other applications within GOV.UK to get the most of this
information.

Before building the application, we first checked for the state of the art of
all the different products within GOV.UK checking if we could re-use some of
this information, so we don't reinvent the wheel.

This is what we found out:

1. We don't have a single place to retrieve all metrics for content items. We
   currently store metrics for organizations (and dashboards) via the
   performance platform, but the way it is structured and the scope of the
   product, make it not a good fit for our mission goal.

1. We store the number of page views in [Search][rummager], so when users search
   in GOV.UK the results are ordered by popularity; the way this information is
   collected [has been reported as Tech debt][ga-tech-debug-trello] and building
   this application will enable [Search][rummager] to use the API and pay the
   tech debt.

1. Data Scientists find it difficult to get and link content and performance
   metrics. Having a single place to look for this information will make their
   daily work easier.

1. Performance Analysts dashboards will also benefit from having metrics from
   multiple sources because, although they have direct access to metrics from
   Google Analytics, they don't have direct access to Feedex or other internal
   applications.

In summary, we looked at the main applications in GOV.UK ([Content
Store][content-store],[Publishing API][publishing-api],[Rummager][rummager]),
and we couldn't find a way to provide the information that we needed to fulfill
the mission goals. As a side benefit, by satisfying the mission goals, we also
find out that we were making GOV.UK suite of applications richer.

[rummager]: https://github.com/alphagov/rummager
[content-store]: https://github.com/alphagov/content-store
[publishing-api]: https://github.com/alphagov/publishing-api
[figure-1-no-trends]: images/fig-01-no-trends.png
[figure-2-with-trends]: images/fig-02-with-trends.png
[figure-3-comparisons]: images/fig-03-comparisons.png
[figure-4-predictions]: images/fig-04-predictions.png
[ga-tech-debug-trello]: https://trello.com/c/mMXm3KQ2/38-google-analytics-integration-is-very-fragile
