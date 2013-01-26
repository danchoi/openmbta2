#!/bin/bash

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
echo "Fixing bad stop times"
sed 's/\<[[:digit:]]\{1\}:/0&/g' data/stop_times.txt > data/stop_times.fixed

echo "running load.sql"
psql mbta < db/load.sql

echo "running denormalize.sql"
psql mbta < db/denormalize.sql

echo "creating indexes"
psql mbta < db/create_indexes.sql
exit 
