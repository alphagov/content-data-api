#!/usr/bin/env groovy

library("govuk")

node("postgresql-9.6") {
  govuk.buildProject(
    postgres96Lint: false,
    rubyLintDiff: false,
    beforeTest: {
      govuk.setEnvar("TEST_COVERAGE", "true")
    }
  )
}
