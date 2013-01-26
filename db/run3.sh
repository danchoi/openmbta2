#!/bin/bash

# Part 3 of recreate data process. Postgis and postgis functions

source db/postgis.sh

echo "psql mbta < db/geom.sql"
psql mbta < db/geom.sql

echo Now run run4.sh
exit

