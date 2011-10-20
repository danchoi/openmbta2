#!/bin/bash

psql -d mbta -f /usr/share/postgresql/8.4/contrib/postgis-1.5/postgis.sql
psql -d mbta -f /usr/share/postgresql/8.4/contrib/postgis-1.5/spatial_ref_sys.sql
psql -d mbta -f /usr/share/postgresql/8.4/contrib/postgis_comments.sql

