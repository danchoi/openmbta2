#!/bin/bash

db=${1:-mbta2}
echo "adding realtime tables"
psql $db < db/realtime_tables.sql

echo "preparing realtime tables"
ruby -Ilib lib/prepare_realtime_tables.rb $db

echo Done creating mbta database
