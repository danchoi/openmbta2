#!/bin/bash

echo "adding realtime tables"
psql mbta < db/realtime_tables.sql

echo "preparing realtime tables"
ruby -Ilib lib/prepare_realtime_tables.rb


echo Done creating mbta database
