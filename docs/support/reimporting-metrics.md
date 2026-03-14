# Requests to re-import Content Data metrics

Occasionally a member of GOV.UK’s Insights team will ask for data to be manually imported.

There’s [a script](https://github.com/alphagov/content-data-api/blob/main/bin/rerun) that creates a Kubernetes Job to 
do the rerun in the background. The script runs from your Mac, so ensure you have AWS credentials for the appropriate 
environment and your kubeconfig is set up correctly to access the cluster.

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

You can check if data is available in [BigQuery](https://console.cloud.google.com/bigquery?project=govuk-content-data&ws=!1m0) 
by running a query:

```
SELECT the_date, cleaned_page_location
FROM `govuk-content-data.ga4.GA4 dataform`
WHERE the_date = "2024-10-29"
LIMIT 5
```
