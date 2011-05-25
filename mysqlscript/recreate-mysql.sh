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
mysqladmin -uroot drop mbta 
echo "Exit status $?"
echo "Dropped mbta in mysql"
mysqladmin -uroot create mbta
echo "Created mbta in mysql"
sleep 1

mysql -uroot  mbta < db/create-mysql.sql

echo "Database created, loading data"
ruby db/gen_load_script_mysql.rb > db/load_mysql.sql

# clean up """ triple quotes
if [[ ! -e data/stops.txt.orig ]]
then
  echo "fixing quotes in data/stops.txt"
  sed 's/"""/"/g' data/stops.txt > data/stops.fixed.txt
  mv data/stops.txt data/stops.txt.orig
  mv data/stops.fixed.txt data/stops.txt
else
  echo "no need to fix quotes in data/stops.txt"
fi

# clean up incomplete stop times, e.g. 9:38:00 => 09:38:00
if [[ ! -e data/stop_times.orig ]]
then
  echo "Fixing bad stop times"
  sed 's/\<[[:digit:]]\{1\}:/0&/g' data/stop_times.txt > data/stop_times.fixed
  mv data/stop_times.txt data/stop_times.orig
  mv data/stop_times.fixed data/stop_times.txt
else
  echo "Bad stop times seems to have been fixed already"
fi

mysql -uroot mbta < db/load_mysql.sql
#psql mbta < db/denormalize.sql
exit
