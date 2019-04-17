# Processing messages from the Publishing API

To detect and track changes to content, we process messages from the Publishing API and update the dimensions editions table. This process is referred to as `Stream` within the codebase. An overview of the process is as follows:

- Publishing API publishes messages about content changes to RabbitMQ
- Content Data consumes messages from RabbitMQ
- Messages that are old, irrelevant or invalid are ignored
- Dimension editions table is updated with the new edition

## Consuming messages

The Publishing API publishes messages about content changes to RabbitMQ. Content Data consumes messages from these queues and processes them in real time. The Content Data consumers to ingest messages from the Publishing API as run via a rake task (link).

## Discarding messages
Messages are filtered for old, irrelevant or invalid payloads. These messages are simply discarded.

Messages are deemed to be old if the latest edition in Content Data has a newer publishing payload version than the incoming message. This prevents messages from being processed twice.

Messages have an associated routing key. This allows us to determine which payloads are not publishing changes. We also discard message which don't have valid values for base_path and schema name, as the essential attributes in creating a new edition.

## Single or Multi part Messages
A message can be either single or multi part. Single part messages represent Content Items for which content is on a single page, whereas multi part messages concern Content Items that span multiple webpages i.e. manuals or detailed guides - have multiple sections each corresponding to a separate webpage.

In Content Data, dimension editions are associated with a single page - so for single part messages this means a single edition, however for multi part message we create multiple editions.

## Parsing a message
Messages are parsed and relevant attributes are transformed to match columns in the dimension editions table.

Editions are identified by the warehouse_item_id which is a combination of content id and the locale. If the message is multi part then the sub part of the base_path is appended to the warehouse_item_id.
Single part message => `<content_id>:<locale>`
Multi part message => `<content_id>:<locale>:<base-path-sub-part>`

## Demoting old editions

Content Data keeps track of which editions are currently live on GOV.UK. This is done by setting the `live` attribute for editions to true. So for newly published editions, old editions for that content item within Content Data need to have `live` set to false.

## Associated Publishing API Event

If we successfully process a message to generate a new edition in Content Data, we also store the associated Publishing API message in the events_publishing_api table.
