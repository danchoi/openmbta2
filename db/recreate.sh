#!/bin/bash

datadir=data
if [ ! -d  $datadir ]
then
  mkdir $datadir
  echo "Please put GTFS csv files in $datadir/"
  exit
fi

if [ ! -e data/agency.txt ]
then
  echo "GTFS files missing from $datadir/"
  exit
fi

echo "Dropping mbta"
dropdb mbta 
echo "Exit status $?"
echo "Dropped mbta"
createdb mbta
echo "Created mbta"
sleep 1
psql mbta < db/create.sql
echo "database created, loading data"
ruby db/gen_load_script.rb > db/load.sql

# clean up incomplete stop time strings, e.g. 9:38:00 => 09:38:00
if [[ ! -e data/stop_times.orig ]]
then
  echo "Fixing bad stop times"
  sed 's/\<[[:digit:]]\{1\}:/0&/g' data/stop_times.txt > data/stop_times.fixed
  mv data/stop_times.txt data/stop_times.orig
  mv data/stop_times.fixed data/stop_times.txt
else
  echo "Bad stop times seems to have been fixed already"
fi

echo "running load.sql"
psql mbta < db/load.sql

echo "running denormalize.sql"
psql mbta < db/denormalize.sql

echo "adding functions"
createlang plpgsql mbta;
psql mbta < db/functions.sql

echo "adding realtime tables"
psql mbta < db/realtime_tables.sql

# postgis installation will vary for each user

echo "Optional: Please download PostGIS and install into the mbta database."
echo "Then run:"
echo "psql mbta < db/linestrings.sql"

echo "Done"
# source db/postgis.sh

exit
