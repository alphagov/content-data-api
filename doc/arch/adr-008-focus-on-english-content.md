# ADR 008: Focus on english content in the first iterations.

28-01-2018

## Context

Some Content Items are written in different languages, so [Publishing-api][1] will return the `content_id` along with all locales assigned to the Content Item.  

## Decision

Focus on content written in English.

The main reason is that we would need different algorithms and libraries to make our application consistent among all the languages / locales. 
If this is a real need, we will support it in future iterations of the Data Warehouse.

### Benefits:

This makes the codebase simpler.   

## Status

Accepted.

[1]: http://github.com/alphagov/publishing-api
