# ADR 016: Rename Content Performance Manager to Content Data API

01-04-2019

## Context

The data warehouse is no longer an application with an UI. It is an API that is
consumed by other applications in order to get metrics through time for content
items of GOV.UK.

The name of the application is not compliant with GOV.UK guidelines for naming.

## Decision

Rename Content Performance Manager to Content Data Admin

## Consequences

The Github repo, code, servers names and puppet configuration needs to be
updated. It is extra work but we think that in the long run it will be
benefitial for GOV.UK and the product.

## Status

Accepted.
