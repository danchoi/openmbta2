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

psql mbta < db/load.sql
# skip denormalize (ver 1)
# add postGIS ; works for ubuntu
echo "Adding plpgsql"
createlang plpgsql mbta;
psql -d mbta -f /usr/share/postgresql/8.4/contrib/postgis-1.5/postgis.sql && \
psql -d mbta -f /usr/share/postgresql/8.4/contrib/postgis-1.5/spatial_ref_sys.sql && \
psql -d mbta -f /usr/share/postgresql/8.4/contrib/postgis_comments.sql

psql mbta < db/linestrings.sql
exit
