# How to proceed with Sentry Errors

We aim to have an [empty list of Errors][1] in Sentry at all times, so with each occurrence in Sentry, we should take action to prevent it from showing again.

The main idea is to have only actionable errors in Sentry because otherwise, they are just noise that could hide important information; [you can read more about errors and how to classify them in GOV.UK developers][2].

## If you are a new developer to the team

1. Subscribe to the Sentry team: #govuk-data-informed-team, which will enable notifications for Content Data Admin and Content Data API.
                                 
## If you find an Error in Sentry (Production)

1. Create a Trello card in the Team board (Backlog).
2. Add the label `sentry` to the Trello card
3. Add a link to the Sentry Error 
4. Include any additional information that you find relevant.
5. Share the link with the Team Lead / Senior Dev / Product Owner.

## If you are resolving a Sentry Error

1. [Classify the error][3], and identify action to take.
2. Fix the problem and write a detailed description of the issue/solution in the Trello card.
3. Share with the team in the weekly Dev session.
4. Mark the error as resolved.

[1]: https://sentry.io/govuk/app-content-data-api/?query=is%3Aunresolved
[2]: https://docs.publishing.service.gov.uk/manual/errors.html#header
[3]: https://docs.publishing.service.gov.uk/manual/errors.html#classifying-errors

