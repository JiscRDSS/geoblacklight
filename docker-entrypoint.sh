#!/bin/bash

echo "Creating log folder"
mkdir -p $APP_WORKDIR/log


if [ "$RAILS_ENV" = "production" ]; then
    # Verify all the production gems are installed
    bundle check
else
    # install any missing development gems (as we can tweak the development container without rebuilding it)
    bundle check || bundle install --without production
fi


# Run any pending migrations
bundle exec rake db:migrate

if [ "$GEOBLACKLIGHT_SEED" = "true" ] ; then
    echo "Seeding Solr with some data"
    bundle exec rake geoblacklight:solr:seed
fi


echo "Starting Geoblacklight"
rm -f /tmp/geoblacklight.pid
bundle exec rails s -p 3010 -b '0.0.0.0' --pid /tmp/geoblacklight.pid

