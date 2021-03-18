# ADR 009: Track metrics by basepath instead of by Content Item

01-06-2018

## Context

We started tracking performance and quality metrics by `content_id`, but after
the first 3 months it was clear that the user needs to track metrics at the
base_path level in Guides and Travel Advice.

## Impact

If a subpath in a Content Item changes, then there is no simple way to track
the performance before/after the change. The data will be stored, but the Data 
Warehouse has no way to join both series of metrics. 

Content Items with no subpages won't be affected because we store the `content_id` 
next to the `base_path` for each Item, so in case we have a `base_path` change 
will be able to track all metrics through time via the `content_id` and `locale`.

## Decision

Track metrics at the base_path level

## Status

Accepted.
