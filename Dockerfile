FROM ruby:2.3

# Setup build variables
ARG RAILS_ENV=production

ENV RAILS_ENV="$RAILS_ENV" \
    LANG=C.UTF-8 \
    RAILS_LOG_TO_STDOUT=yes_please \
    BUNDLE_JOBS=2 \
    APP_PRODUCTION=/geoblacklight.production/ \
    APP_WORKDIR="/geoblacklight.$RAILS_ENV"

# install node.js v7 and postgres libraries
# nb it isn't necessary to run "apt-get update" because this runs via the nodesource script
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
    && apt-get install -y --no-install-recommends \
    libpq-dev \
    nodejs \
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# copy gemfiles to production folder
COPY Gemfile Gemfile.lock $APP_PRODUCTION

# install gems to system - use flags dependent on RAILS_ENV
RUN cd $APP_PRODUCTION && \
    bundle config build.nokogiri --use-system-libraries \
    && if [ "$RAILS_ENV" = "production" ]; then \
            bundle install --without development test; \
        else \
            bundle install --without production; \
        fi

# copy the application
COPY . $APP_PRODUCTION
COPY docker-entrypoint.sh /bin/

# generate production assets if production environment
RUN if [ "$RAILS_ENV" = "production" ]; then \
        cd $APP_PRODUCTION \
        && SECRET_KEY_BASE_PRODUCTION=0 bundle exec rake assets:clean assets:precompile; \
    fi

WORKDIR $APP_WORKDIR

CMD ["/bin/docker-entrypoint.sh"]
