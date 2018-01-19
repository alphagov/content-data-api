# ADR 006: Track metrics through a time dimension

18-01-2018

## Context

We would benefit from having a central repository of integrated data from multiple sources that stores current and historical information, and use this data to create analytical reports and performance indicators to support the publishing workflow within GOV.UK.

This is actually difficult to achieve as we have the information dispersed across different applications that are currently designed to support transactional operations and not analytical reporting of integrated data.
 
## Decision

Build a data warehouse(*) that maintains a copy of the information of the transactional systems.

(*) We will be using a PostgreSQL database in the first iteration, we will be exploring other existing solutions for data warehouses in future iterations once we have validated this approach. 

## Status

Accepted.
