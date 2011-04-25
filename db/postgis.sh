#!/bin/bash

# add postGIS ; works for ubuntu
createlang plpgsql mbta ;
psql -d mbta -f /usr/share/postgresql/8.4/contrib/postgis.sql && \
psql -d mbta -f /usr/share/postgresql/8.4/contrib/spatial_ref_sys.sql && \
psql -d mbta -f /usr/share/postgresql/8.4/contrib/postgis_comments.sql


