# ADR 004: Remove Term Generation Tool

16-01-2018

## Context

The Term Generation Tool [was merged in July 2017][add-tool-pr]. 

The Taxonomy Team was exploring ways to generate `taxons` to improve the process of Content Transformation in GOV.UK.

We had planned to integrate this tool with the Content Audit Tool and the Content Performance Manager as a suite of tools for Content Transformation, but all of them have followed different paths.

1. We are re-designing the CPM so we store metrics through time, and work with multiple dimensions of data.
2. The Content Audit Tool is being moved to its own repo and we are not developing it any further (for the time being).
3. The Term Generation tool is not under development nor use at the moment.

## Decision

[]Remove the Term Generation Tool][remove-tool-pr] and tag it in `Git`.

## Status

Accepted.

[add-tool-pr]: https://github.com/alphagov/content-performance-manager/pull/173
[remove-tool-pr]: https://github.com/alphagov/content-performance-manager/pull/468
