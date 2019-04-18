# Resources shared with other apps by content-data-api

## Backend machines

Both of our apps live on and share resources with all apps on the `backend` machines - These are:

* asset-manager
* hmrc-manuals-api
* short-url-manager
* cache-clearing-service
* imminence
* sidekiq-monitoring
* collections-publisher
* link-checker-api
* signon
* contacts
* local-links-manager
* specialist-publisher
* content-audit-tool
* manuals-publisher
* support
* content-data-admin
* maslow
* support-api
* content-data-api
* publisher
* transition
* content-performance-manager
* release
* travel-advice-publisher
* content-publisher
* search-admin                                      
* content-tagger
* service-manual-publisher

We are a risk to other applications on these hosts and we need to look at:

* RAM

  Excessive memory usage will de-stabilise the host and affect all applications running on it.
  We have icinga alerts checking this

* CPU

  High CPU usage will also affect other services.
  We also have icinga alerts for this.

* Disk usage

  We have had problems with logs filling the hard disk. We already have a card in the backlog to address this.
  There are icinga alerts for `high disk time` and `low available disk space` on various partitions.

We have very low volume traffic to `content-data-admin`. 

The part of `content-data-api` most likely to be a risk to other applications is processing the stream of 
RabbitMQ messages from publishing-api. 
This happens during office hours and the volume is quite high.

## Database

* `warehouse-postgresql-1.backend ` is on it's own VM in carrenza so we have no problem with resource contention.

* This will be a managed service in AWS so shouldn't have a problem. we already have a card for monitoring the database.

## Redis

We use a shared instance of redis for sidekiq background jobs. There is a card in the backlog to deal with this.

## SSO

- not sure if this will be a problem

## RabbitMQ, we consume messages from 6 queues

If our message consumers are not working, or not processing messages fast enough, RabbitMQ can run out of memory.
We need to ensure these consumers are rock-solid to avoid impacting the publishing pipeline.

There are alerts in Icinga for:

* No consumers listening to queue.
* The queue length has grown too long.

## GDS services:

### support-api

We retrieve the number of feedex comments from support-api as part of the overnight ETL processing.
The volume or requests is low and out of hours. We should be aware of this during large batch processes
(back-filling daily metrics)

### support app

Feedback from `content-data` is collected by the support app. We are unlikely to get enough feedback to cause a 
problem here.

## GA 

Managed by google so shouldn't be a problem. The only thing that may cause a problem is any quotas we may have. 
This should only cause problems whend we are back-filling data.

## Graphite

We send a number of metrics to graphite. Unlikely to cause a problem as the volumes we send are quite small for graphite.

## Sentry

We need to be aware of quotas for sentry. If we have a problem with a bulk process that causes us to send a lot of exceptions to sentry,
we are likely to exceed our quotas.

The Etl process will only send on exception to Sentry for each thing (Internal searches, user feedback etc.) so this shouldn't cause a problem.

If we have a problem with the stream processing we could send errors to Sentry at a rate of 1 per message received, so again,
this processing should be looked at.

## Logit

This is the same problem as disk usage above. We can mitigate problems here by ensuring we don't log too much when there is a
problem.
