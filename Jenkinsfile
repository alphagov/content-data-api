#!/usr/bin/env groovy

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'
  govuk.buildProject(
    beforeTest: {
      govuk.setEnvar("TEST_COVERAGE", "true")
    }
  )
}
