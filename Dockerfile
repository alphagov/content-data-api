FROM ruby:2.5.1
MAINTAINER Government Digital Service <govuk-dev@digital.cabinet-office.gov.uk>

RUN \
  apt-get update && apt-get install -y --no-install-recommends --no-upgrade \
    nodejs \
    postgresql-client \
  && rm -rf /var/lib/apt/lists/*

RUN \
  apt-get update && apt-get install -y --no-install-recommends --no-upgrade \
    libfontconfig \
  && mkdir /tmp/phantomjs \
  && curl -L https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 | tar -xj --strip-components=1 -C /tmp/phantomjs \
  && mv /tmp/phantomjs/bin/phantomjs /usr/local/bin \
  && rm -rf /tmp/phantomjs \
  && rm -rf /var/lib/apt/lists/*

RUN \
  yes | gem update --no-document -- --use-system-libraries && \
  yes | gem update --system --no-document -- --use-system-libraries && \
  yes | gem cleanup --

WORKDIR /usr/src/app

COPY .ruby-version Gemfile* ./
RUN bundle install

COPY . .

ENV PATH /usr/src/app/bin:$PATH
