#!/bin/bash

# Part 3 of recreate data process. Run run1.sh and run2.sh first.

echo "adding realtime tables"
psql mbta < db/realtime_tables.sql

echo "preparing realtime tables"
ruby -Ilib lib/prepare_realtime_tables.rb

# postgis installation will vary for each user

echo "Optional: Please download PostGIS and install into the mbta database."
echo "Then run:"
echo "psql mbta < db/geom.sql"

echo "Done"
# source db/postgis.sh

exit
