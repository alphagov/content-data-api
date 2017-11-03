# Deploy a PR to Heroku

1. Install the [the Heroku Command Line Interface (CLI)][heroku-cli]
2. [Login][login-terminal] from your terminal: you only need to do it once
3. Deploy your current branch from your VM with:

```system
rake heroku:deploy[IDENTIFIER]`
````

You can also include the following optional parameters: `organisation_name`, `number_of_content_items` and  `link_types`

For example, to import `500` content items from `HMRC`, we would do:

```system
rake heroku:deploy[10,"HM Revenue & Customs",500]
```

### Heroku limit

[Heroku has a limit of 10000 rows][heroku-limit] in a database, so we have hardcoded the script to only import that many objects. This limit covers content items, links and other rows such as allocations that we would need for testing.

[heroku-cli]: https://devcenter.heroku.com/articles/heroku-cli
[login-terminal]: https://devcenter.heroku.com/articles/heroku-cli#getting-started
[heroku-limit]: https://devcenter.heroku.com/articles/heroku-postgres-plans#hobby-tier
