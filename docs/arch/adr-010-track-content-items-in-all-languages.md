# ADR 011: Track content items in all languages

18-06-2018

## Context

In [adr-008][1] we agreed on focusing only on English pages.

We have noticed during the last few months that this restriction is causing more
issues than benefits, because:

- We have Content Items with the same `content_id` and different `locale`s.
- We needed to handle edge cases when retrieving the information from Publishing API in order to work around only retrieving English language content.

## Impact

We have accepted that the quality metrics about content won't be accurate for these pages.

## Decision

Track Content metrics of all Content Item regardless of their locale.

## Status

Accepted.

[1]: https://github.com/alphagov/content-performance-manager/commit/27a0942346f3b0a2050ccd74b1a3d00825fa2ff9
