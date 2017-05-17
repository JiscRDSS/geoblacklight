#!/bin/bash

echo "Creating tmp and log, clearing out PIDs"
mkdir -p $APP_HOME/tmp/pids $APP_HOME/log
rm  -f $APP_HOME/tmp/pids/*

# Install any missing gems
bundle check || bundle install

# Run any pending migrations
bundle exec rake db:migrate

if [ "$RAILS_ENV" = "production" ]; then
    echo "Compiling assets..."
    bundle exec rake assets:clean assets:precompile
fi

echo "Seeding Solr with some data"
bundle exec rake geoblacklight:solr:seed

echo "Starting Geoblacklight"
bundle exec rails s -p 3010 -b '0.0.0.0'

