# Re-queue all content from the Publishing API

This is a rake task in the Publishing API. It will queue messages to RabbitMQ that the Content Data API will consume. This was initially created to bootstrap the data in the Content Data API, and shouldn't need re-running.

To run the rake task, use the `run_rake_task` job on the deployment Jenkins and provide the routing key as below:

```bash
queue:requeue_all_the_things[bulk.data-warehouse]
```

## Details

* PR to add [Task to queue messages for all content](https://github.com/alphagov/publishing-api/pull/1242)
* Source for the [rake task](https://github.com/alphagov/publishing-api/blob/master/lib/tasks/queue.rake#L53)