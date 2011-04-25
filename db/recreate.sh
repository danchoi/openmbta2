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
# add postGIS ; works for ubuntu
echo "Adding plpgsql"
createlang plpgsql mbta ;
psql -d mbta -f /usr/share/postgresql/8.4/contrib/postgis.sql && \
psql -d mbta -f /usr/share/postgresql/8.4/contrib/spatial_ref_sys.sql && \
psql -d mbta -f /usr/share/postgresql/8.4/contrib/postgis_comments.sql

psql mbta < db/create.sql
echo "database created, loading data"
ruby db/gen_load_script.rb > db/load.sql
psql mbta < db/load.sql

exit
