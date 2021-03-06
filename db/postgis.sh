#!/bin/bash

db=${1:-mbta2}

if [[ -d "/usr/local/Cellar/postgis/2.0.1/share/postgis" ]]
then
  echo Installing from /usr/local/Cellar/postgis/2.0.1/share/postgis
  psql -d $db -f /usr/local/Cellar/postgis/2.0.1/share/postgis/postgis.sql
  psql -d $db -f /usr/local/Cellar/postgis/2.0.1/share/postgis/spatial_ref_sys.sql
  psql -d $db -f /usr/local/Cellar/postgis/2.0.1/share/postgis/postgis_comments.sql

elif [[ -d "/usr/share/postgresql/8.4/contrib" ]]
then
  echo Installing from /usr/local/Cellar/postgis/2.0.1/share/postgis
  psql -d $db -f /usr/share/postgresql/8.4/contrib/postgis-1.5/postgis.sql
  psql -d $db -f /usr/share/postgresql/8.4/contrib/postgis-1.5/spatial_ref_sys.sql
  psql -d $db -f /usr/share/postgresql/8.4/contrib/postgis_comments.sql
else
  echo "ERROR: No postgis files found"
  exit 1
fi


