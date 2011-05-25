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
mysql -uroot mbta < db/load_mysql.sql
#psql mbta < db/denormalize.sql
exit
