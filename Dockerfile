FROM ruby:2.3

ENV LANG=C.UTF-8 \
    RAILS_LOG_TO_STDOUT=yes_please \
    APP_HOME=/geoblacklight \
    BUNDLE_GEMFILE=/geoblacklight/Gemfile \
    BUNDLE_JOBS=2 \
    BUNDLE_PATH=/bundle

# install node.js v7 and postgres libraries
# nb it isn't necessary to run "apt-get update" because this runs via the nodesource script
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
    && apt-get install -y --no-install-recommends \
    libpq-dev \
    nodejs \
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

ADD docker-entrypoint.sh $APP_HOME/docker-entrypoint.sh

WORKDIR $APP_HOME

ENTRYPOINT $APP_HOME/docker-entrypoint.sh
