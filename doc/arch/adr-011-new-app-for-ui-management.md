# ADR 011: Create a new application for UI management 

18-07-2018

## Context

We aim to provide Content Designers and Managing Editors with the data that they need to manage content at scale and make informed decisions around content; this implies providing them with a set of pages with time series of metrics, aggregated results, and other stats from the Data Warehouse.

It is not clear yet how big/complex the solution should be because we are still in early days, but as per user research, we have found out that:

1. Users are keen to have performance data about their content
2. Users will need an application to fulfil their content management needs. 

So, it seems that the application will continue having its own line of development for more quarters while we actively do user research on it.

At this moment, the next step for the development team is to build the UI for the first iteration of the tool, so we would need to decide where this new functionality should live.

We are considering two options:

Option 1: Create a new application, and access the Data Warehouse via an API. 

Option 2: Add the UI to the Data Warehouse application.
 
### Option 1: Create a new application, and access the Data Warehouse via an API

We would have two applications:

1. Frontend app (name to be confirmed) to render the UI.  
2. Backend app (content-performance-manager) that exposes data via an API.

**Notes**: 

1. It might be necessary to rename the `content-performance-manager` to something ending in `-api` to be consistent with the existing name conventions across GOV.UK.
2. The [existing api][1] is in a very early stage. We will need to evolve it to fulfil the needs of this application. These are [some ideas from @tijmenb to decouple the API from the main client][2].

Pros:
 
 - It better reveals the purpose of the Data Warehouse: a source of data for other applications to use.
 - It enables having a robust API so other applications could quickly benefit from having a stable API with well-defined endpoints.
 - The architecture is easier to explain.
 - It seems more consistent with the way GOV.UK has designed other applications.
 - If we change the way we manage the data warehouse (even a complete rewrite), we can do this without impacting the content management tools.

### Option 2: Build the UI in the same application (Content Performance Manager) 

We would need to: 

1. Have a logical (not physical) separation within the application, so the code related to the UI only depends on the same services that the API relies on.
2. The UI code would be able to access to more advanced queries without having to expose them via the API. 
3. The Frontend developers would be working on a subset of the application that is delimited via modules/folders.

Pros:

 - There is no extra infrastructure maintenance/configuration. 
 - The application is deployed once, there is no need to synchronise the deployments of the backend/frontend.
 - We can evolve the application without touching the API, which impacts in having a stable API free from frequent versioning.
 - The development pace is a bit faster because the distance to the source of the data is shorter, and don't depend on remote calls.

## Decision

Create a new application to host the UI for Content Management at scale

### Consequences

1. We need to create a new application, provision it within GOV.UK and actively monitor it.
2. We will need to explore [ways to keep the API as stable as possible][2].
3. We will need to create some integration/system tests to ensure that both applications are working as expected.

## Status

Accepted.


[1]: https://content-performance-api.publishing.service.gov.uk/
[2]: https://github.com/alphagov/content-performance-manager/pull/798#discussion_r203503129
