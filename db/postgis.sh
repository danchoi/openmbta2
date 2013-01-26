#!/bin/bash

if [[ -d "/usr/local/Cellar/postgis/2.0.1/share/postgis" ]]
then
  echo Installing from /usr/local/Cellar/postgis/2.0.1/share/postgis
  psql -d mbta -f /usr/local/Cellar/postgis/2.0.1/share/postgis/postgis.sql
  psql -d mbta -f /usr/local/Cellar/postgis/2.0.1/share/postgis/spatial_ref_sys.sql
  psql -d mbta -f /usr/local/Cellar/postgis/2.0.1/share/postgis/postgis_comments.sql

elif [[ -d "/usr/local/Cellar/postgis/2.0.1/share/postgis" ]]
then
  echo Installing from /usr/local/Cellar/postgis/2.0.1/share/postgis
  psql -d mbta -f /usr/share/postgresql/8.4/contrib/postgis-1.5/postgis.sql
  psql -d mbta -f /usr/share/postgresql/8.4/contrib/postgis-1.5/spatial_ref_sys.sql
  psql -d mbta -f /usr/share/postgresql/8.4/contrib/postgis_comments.sql
else
  echo "ERROR: No postgis files found"
fi


