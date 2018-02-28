#!/usr/bin/env groovy

library("govuk@add-brakeman")

node {
  govuk.buildProject(
    beforeTest: {
      govuk.setEnvar("TEST_COVERAGE", "true")
    }
  )
}
