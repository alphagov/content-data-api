#!/usr/bin/env groovy

library("govuk")

node {
  govuk.buildProject(
    beforeTest: {
      govuk.setEnvar("TEST_COVERAGE", "true")
    }
  )
}
