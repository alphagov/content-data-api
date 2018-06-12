#!/usr/bin/env groovy

library("govuk")

node {
  govuk.buildProject(
    postgres96Lint: false,
    beforeTest: {
      govuk.setEnvar("TEST_COVERAGE", "true")
    }
  )
}
