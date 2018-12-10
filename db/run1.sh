#!/bin/bash
set -e

db=${1:-mbta}

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

echo "Dropping $db"
dropdb $db
echo "Exit status $?"
echo "Dropped $db"
createdb $db
echo "Created $db"
sleep 1
psql $db < db/create.sql
echo "database created, loading data"
ruby db/gen_load1.rb $db > db/load1.sh 
ruby db/gen_load_script.rb | grep -v checkpoints | grep -v multi_route_trips > db/load.sql

# clean up incomplete stop time strings, e.g. 9:38:00 => 09:38:00

echo "Fixing bad stop times"

# Time point may be corrupted and a "" instead of 1

sed -e 's/\<[[:digit:]]\{1\}:/0&/g' data/stop_times.txt  | 
  sed -E 's/"",([^,]*)$/0,\1/' |
  awk 'BEGIN {OFS=","; FS="," } { $NF="1"; print }' > data/stop_times.fixed

# Remove column from trips
# psql $db -c 'alter table trips drop column finished_at'

echo "running load1.sh and load.sql"
bash db/load1.sh 
psql $db  < db/load.sql >/dev/null

echo "running denormalize.sql"
psql $db < db/denormalize.sql

echo "creating indexes"
psql $db < db/create_indexes.sql

echo "adding functions to $db"
set +e
createlang plpgsql $db;
psql $db < db/create_functions.sql
set -e

echo "creating cache tables"
psql $db < db/cache_tables.sql

# db/postgis.sh $db
# echo "psql $db < db/geom.sql"
# psql $db < db/geom.sql

echo "adding realtime tables"
psql $db < db/realtime_tables.sql
psql $db < trips-today.sql

echo "Adding realtime data"
curl -sL https://cdn.mbta.com/realtime/TripUpdates.pb | gtfs-realtime t | rt/import.sh $db




