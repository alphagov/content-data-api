#!/usr/bin/env groovy

library("govuk")

node("postgresql-9.6") {
  govuk.buildProject(
    beforeTest: {
      govuk.setEnvar("TEST_COVERAGE", "true")
    }
  )
}
