## Problem 

1. Discrepancies in the expected numbers of content items that need to be audited when we compare them with the existing spreadsheets. 
2. Themes do not represent the input of an Audit.
  
## Decision

1. Introduce the notion of an `Audit Plan` (defined below) that models the input of an audit.
2. Do not use Themes in the Content Audit Tool, and rely on primary organisations.

## Audit plans

An audit plan is a set of content items that need auditing by a team of Content Auditors. 

It is conformed of:

- A set of subscription rules 
- A set of formats to exclude
- A set of content items to include
- A set of content items to exclude

As of now, as we are relying on organisations, we will limit the subscription rules to a single rule that represents the content that belongs an organisation.
 
## Terms

The following list represents concepts that have been used in the process to define an inventory. 
We are writing them down here as they have been a source of misunderstanding for the team.

A **theme** is a high level grouping criteria for all the content that GOV.UK is currently hosting; It is subject related, and it attempts to explain an approximation of the 'aboutness' of content items that would reside in a specific theme. 

An **inventory plan** is a set of rules that define the content that belongs to a theme. 

The **inventory sheet** refines an inventory plan by excluding formats by adding/removing sets of content items.

An **audit sheet** is what a the department is going to audit. It is the result of multiple refinements (`theme` -> `inventory plan` -> `inventory sheet` -> `audit sheet`), and contains the list of content items that need auditing.

