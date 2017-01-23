# Deploying the application

## Heroku

1\. Setup the environment to deploy to Heroku

```bash
$ rake heroku:prepare # Only need to be done once
```

2\. Deploy to Heroku

Try one of the following methods:

##### Use the deploy script
```bash
$ rake heroku:deploy
```

##### Use the heroku deploy commands
```bash
$ git push heroku master
```

followed by:

```bash
$ heroku rake db:migrate
```

To see updated (or data in new fields) data on heroku, you need to run all of the import tasks:

```bash
$ heroku rake import:all_organisations
$ heroku rake import:content_items_by_organisation[{department-slug}]
$ heroku rake import:number_of_views_by_organisation[{department-slug}]
```

## Integration

This happens automatically as post build action when the `master` branch is successfully builds on the Jenkins CI environment.

The application can also be deployed manually via the `Deploy_App` job.
