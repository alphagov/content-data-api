# GOVUK-LINT-RUBY

We're using the `govuk-lint` Gem that includes Rubocop and the GOV.UK styleguide rules in the project.

### Jenkins

We run `bundle exec govuk-lint-ruby` as part of the test suite executed on Jenkins (see jenkins.sh). Behind the scenes this runs Rubocop with a set of cops defined in the `govuk-lint` gem.

```bash
$ bundle exec govuk-lint-ruby --format clang
```

### Running locally

Testing for violations in the entire codebase (used by `jenkins.sh`):

```bash
$ bundle exec govuk-lint-ruby
```

Testing for violations in code committed locally that's not present in origin/master (useful to check code committed in a local branch):

```bash
$ bundle exec govuk-lint-ruby --diff
```

Testing for violations in code staged and committed locally that's not present in origin/master:

```bash
$ bundle exec govuk-lint-ruby --diff --cached
```
