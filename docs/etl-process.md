# Collecting user metrics

This is a general overview of how we collect and store user metrics. 
Metrics are collected on a daily basis from a variety of data sources.
Monthly aggregations of the daily score are then pre-calculated and stored in a separate table.

These processes run as Rake task daily in the early morning from Jenkins. They are referred to as ETL processors in the codebase as they follow a Extract, Transform and Load (ETL) design pattern.

The process begins with the MainProcessor which co-ordinates:
- setting up the Facts metric table
- running the sub-processors for each of the data sources to collect daily metrics
- the re-aggregation of the monthly metrics
- refreshing the aggregation views for larger time periods

## Setting up the Facts metrics table

Before collecting data source the MainProcessor:
- Adds empty rows the Facts metrics table (where we store daily metrics) for each edition we would like metrics about. The editions we collect metrics for are those currently live on GOV.UK.
- Makes sure there is an Date dimension for the day collecting metrics.

## Processors for data sources

We have processors for the following data sources:
- Google Analytics: Views And Navigation (pageviews, unique pageviews, page time etc)
- Google Analytics: User Feedback (Was this useful? Yes or No)
- Google Analytics: Internal Searches (Number of searches from the page)
- Feedback Explorer (Number of feedback comments)

These individual processors are responsible for making the relevant API calls and storing the data in the facts metrics table.

The processors co-ordinate the following:
- making relevant API calls, usually through the associated service class
- storing the data from the API in temporary Events table
- transforming the API data from to be suitable to store in the database
- loading the values into the Fact metrics table

The intermediate Events table allows us to collect data from multiple API calls efficiently and prevent incomplete updates of the Facts metrics table i.e we have data for some editions and not others.

## Aggregating month metrics

For each of the metrics we pre-calculate the aggregate value for each month. For each day we collect daily metrics for we must update aggregate score for that month containing that day. 

## Refresh views

Our user facing API supports searching for content across specified time-periods (i.e. past-30-days, past-3-months, past-year, etc..). To enable this we use materialized views which aggregate monthly metrics
into each of the respective time periods.
