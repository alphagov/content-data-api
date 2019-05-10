# ADR 017: Remove Sidekiq to process messages

10-05-2019

## Context

Content Data API is subscribed to events in PublishingAPI via RabbitMQ. We made an previous decision to process the events using Sidekiq workers.

```
class Consumer
    def process(rabbit_mq_message)
      ...
      # Queue job in Sidekiq to process job later
      Streams::MessageProcessorJob.perform_later(message.payload, message.delivery_info.routing_key)
      ...
    end
    ...
end    
```

The reasons for our original decision to use Sidekiq were:

1. It allows us to reuse the existing monitoring capabilities in GOV.UK
2. It supports out-of-the-box exponential backoff algorithm for retries.
3. We had issues with running the entire process in a database transaction.

We’ve found that GOV.UK also has existing monitoring for RabbitMQ and Sidekiq only adds more complexity, making it more difficult to debug and track issues that occur.

At first, the ability to retry was desirable due to a particular constraint of the system. That is that transactions for editions for the same content item cannot occur concurrently. We emulate serial processing by retrying messages where a transaction error has occurred. However in most other cases, retrying a message doesn’t resolve an error. Messages can be endlessly retried and cause excessive logging. We should be relying on a system that handles errors appropriately, rather than hoping a retry will fix an issue.

Additionally, since implementing this we’ve learnt of the following disadvantages:

1. Sidekiq is an extra point of failure.
2. Code is less maintainable as it requires more effort to write tests.
3. Sidekiq adds significant overhead to processing each message.
4. Sidekiq adds overall complexity to the system.

Bunny (Ruby RabbitMQ client) supports running multiple consumer per queue. We should be able to use concurrent consumers to replace Sidekiq. 

## Decision

We should move message processing into the consumers themselves and remove Sidekiq. To increase throughput, we can run multiple consumers in concurrent threads. Initially, to address the issue with concurrent transactions we can set up consumers to retry a message that failed due to a transaction error.

### Consequences


## Status

Accepted.
