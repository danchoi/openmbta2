#!/bin/bash

db=${1:-mbta2}

echo Using DB: $db
datadir=data
if [ ! -d  $datadir ]
then
  mkdir $datadir
  echo "Please put GTFS csv files in $datadir/"
  exit 1
fi

if [ ! -e data/agency.txt ]
then
  echo "GTFS files missing from $datadir/"
  exit 1
fi

echo "Dropping mbta"
dropdb $db
echo "Exit status $?"
echo "Dropped mbta"
createdb $db
echo "Created mbta"
sleep 1
psql $db < db/create.sql
echo "database created, loading data"
ruby db/gen_load_script.rb > db/load.sql

# clean up incomplete stop time strings, e.g. 9:38:00 => 09:38:00
echo "Fixing bad stop times"
sed 's/\<[[:digit:]]\{1\}:/0&/g' data/stop_times.txt > data/stop_times.fixed

echo "running load.sql"
psql $db  < db/load.sql

echo "running denormalize.sql"
psql $db < db/denormalize.sql

echo "creating indexes"
psql $db < db/create_indexes.sql
exit 
