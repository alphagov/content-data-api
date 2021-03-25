# Use compound id instead of a random UUID

26-Sep-2018

## Context

In the Data Warehouse [we have decided to track content through time and use a unique identifier][2] that guarantees consistency across time.

Our initial approach was to use a random uuid:

```ruby
 SecureRandom.uuid #=> "1ca71cd6-08c4-4855-9381-2f41aeffe59c"
```

Following some feedback from @tijmenb, we have decided to use a compound id for each on of our items. The compound id will have the following format depending of the type of Content Item:

### Single content items (no multi-path)

We concat the `content_id` and the `locale` for Content Item that don't have multiple paths. 

```ruby
  warehouse_item_id = "1ca71cd6-08c4-4855-9381-2f41aeffe59c:en"
```

### Multipart content items (item with multiple paths)

We concat the `content_id`, the `locale` and the `base_path` for Content Items that have multiple paths (Guides, Travel Advice...)

```ruby
  warehouse_item_id = "1ca71cd6-08c4-4855-9381-2f41aeffe59c:en:/marriage-abroad"
```

We won't be able to track changes to base_paths, but as of today we have no simple way to work around this. This is a known issue that could be mitigated by getting aggregations at the parent level.

## Decision

1. Use a compound unique id following the naming conventions described above.
2. Name it `warehouse_item_id`

## Consequences

1. The unique identifier is not a random number. It has a meaning which mimics the existing rules that define uniqueness across all GOV.UK content
2. It is consistent with [Content Publisher][1]: the new publishing application for content.
3. The unique identifier enables easy integration for external applications as they can easily build URLs that depend on the unique id.

[1]: https://github.com/alphagov/content-publisher
[2]: https://github.com/alphagov/content-performance-manager/blob/1f9f961897/doc/arch/adr-014-track-attribute-changes-per-basepath.md
