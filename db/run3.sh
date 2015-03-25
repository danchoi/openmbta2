#!/bin/bash

# Part 3 of recreate data process. Postgis and postgis functions

db=${1:-mbta2}

db/postgis.sh $db

echo "psql $db < db/geom.sql"
psql $db < db/geom.sql

echo Now run run4.sh
exit

