## Development workflow

## Creating a Pull Request

As the Pull Request author:

1. Open a PR with the changes you want to merge. _Do not open the PR against `master` if the changes affect a prototype_.

2. Add the appropriate label(s):

  * Prototype - if this change only affects an existing prototype.
  * Don't merge - to make it very clear that this shouldn't be merged.

3. Move the associated Trello card from "In progress" to "Code review".


## Reviewing a Pull Request (optional for prototypes)

As the Pull Request reviewer:

1. Assign yourself to the Pull Request.

2. Review the Pull Request.

3. Add a comment to say that the PR looks good if/when you're happy with it.


## Product review

As the Pull Request author:

1. Add the "In product review" label to allow developers to see at a glance that the PR do not need any immediate action.

2. [Deploy the branch to Heroku][deploy-to-heroku], adding the link to associated Trello card.

3. Move the associated Trello card from "Code review" to "In product review".


As a Product owner:

1. Ensure the card meets the user need described in the Trello card.

2. Move the associated Trello card from "Product review" to "To merge" if/when you're happy with it.

   If changes must be made, make the requested changes and start the process again by updating your original Pull Request; getting another code review; and resubmitting for product review.

3. Add a comment to the associated Trello card to let the relevant people know it's ready to deploy.


## Merging a Pull Request

As the Pull Request author:

1. Rebase the branch on master.

2. Force push the branch to GitHub.

3. Click "Merge pull request".

4. Click "Delete branch".


## Deployment

As a Developer:

1. Create release notes in GitHub. 

2. Inform the product owner about the release so the relevant users can be informed.

3. Deploy following the standard GOV.UK process.

[deploy-to-heroku]: https://github.com/alphagov/content-performance-manager/blob/master/doc/deploy-to-heroku.md
