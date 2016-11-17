#!/bin/bash -x

set -e

bundle exec govuk-lint-ruby --format clang

RAILS_ENV=test TEST_COVERAGE=true bundle exec rake test

bundle exec rake assets:precompile
