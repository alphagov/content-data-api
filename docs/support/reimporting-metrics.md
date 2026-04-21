# Requests to re-import Content Data metrics

Occasionally a member of GOV.UK’s Insights team will ask for data to be manually imported.

There’s [a script](https://github.com/alphagov/content-data-api/blob/main/bin/rerun) that creates a Kubernetes Job to 
do the rerun in the background. The script runs from your Mac, so ensure you have AWS credentials for the appropriate 
environment (this is likely to be `production`) and your kubeconfig is set up correctly to access the
cluster.

To re-import a single date:

```
bin/rerun 2024-08-03
```

Command run in the job: 

```
rake etl:rerun_main_list[2024-08-03]
```

To re-import a set of dates:

```
./rerun.rb 2024-08-03,2024-09-05,2025-01-31
```

Command run in the Job: 

```
rake etl:rerun_main_list[2024-08-03,2024-09-05,2025-01-31]
```

Rake task code: https://github.com/alphagov/content-data-api/blob/main/lib/tasks/etl.rake#L83-L94

## Monitoring task progress

The `bin/rerun` script will provide a kubernetes command for tailing the rake 
task's logs, e.g.:

```sh
Job adhoc-etl-rerun-48dddc183822142a created.
Run this command to follow logs:
  kubectl -n apps logs -f job.batch/adhoc-etl-rerun-48dddc183822142a
```

You'll be able to monitor the progress of the import job, which takes around
50 mins to produce output describing the import for a single day:

- main process (metrics, ga_views_navigation, ga, ga_search, feedex)
- monthly and search aggregations

You should see log output including messages similar to:

```
Running Etl::Main process for 2026-04-17

Process: 'main' started at 2026-04-21 14:52:06
Process: 'metrics' started at 2026-04-21 14:52:06
Process: 'metrics' : about to get the Dimensions::Date
Process: 'metrics' : got the Dimensions::Date
Process: 'metrics' : processing 5000 items in batch 0
...
Process: 'ga_views_navigation' started at 2026-04-21 15:07:05
Process: 'ga' : Processing 10000 events in batch 1
Process: 'ga_search' ended at 2026-04-21 15:16:13, duration: less than a minute
Process: 'feedex' ended at 2026-04-21 15:16:15, duration: less than 5 seconds
Process: 'main' ended at 2026-04-21 15:16:15, duration: 24 minutes

finished running Etl::Main for 2026-04-17

Running monthly and search aggregations for 2026-04-30

Process: 'aggregations_monthly' ended at 2026-04-21 15:19:31, duration: 3 minutes
Process: 'search_last_thirty_days' ended at 2026-04-21 15:27:40, duration: 8 minutes
Process: 'search_last_three_months' ended at 2026-04-21 15:42:26, duration: 9 minutes
Process: 'search_last_six_months' ended at 2026-04-21 15:52:02, duration: 10 minutes
Process: 'search_last_twelve_months' ended at 2026-04-21 16:03:01, duration: 11 minutes
```


## Verifying import in BigQuery

You can check if the data you expect to have been imported is available in 
[BigQuery](https://console.cloud.google.com/bigquery?project=govuk-content-data&ws=!1m0) 
by running a query:

```
SELECT the_date, cleaned_page_location
FROM `govuk-content-data.ga4.GA4 dataform`
WHERE the_date = "2024-10-29"
LIMIT 5
```
