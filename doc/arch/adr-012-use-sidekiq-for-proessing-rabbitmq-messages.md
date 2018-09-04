# ADR 012: Process each RabbitMQ message in a Sidekiq Job

04-09-2018

## Context

Content Performance Manager is subscribed to events in PublishingAPI via RabbitMQ. At the moment we process the events synchronously:

```
class Consumer
    def process(rabbit_mq_message)
      # preprocess
      do_process(rabbit_mq_message)
      # post-process
    end
end    
```

Each item should run within a transaction, so we effectively need to wrap it with:

```
ActiveRecord::Base.transaction do
  do_process(rabbit_mq_message)
end
```

With this configuration we have had unexpected side effects because the database seems to reject the connections via the following message:

```
`PG::ConnectionBad: PQsocket() can't get socket descriptor: BEGIN
``` 

We debugged the database for many hours, and we got the feeling that the connections might be shared among multiple threads, and this only happens in staging because we have more RabbitMQ workers / hosts.

In any case, we had already planned using Sidekiq for processing the messages because:

1. It allows us to reuse the existing monitoring capabilities in GOV.UK
2. It supports out-of-the-box exponential backoff algorithm for retries.

## Decision

Process all the events from Publishing API in Sidekiq Jobs

### Consequences

Define a new ActiveJob job to process each message.

## Status

Accepted.
