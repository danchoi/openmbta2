# OpenMBTA2

A clean rewrite of OpenMBTA.

## Setup

Assumes PostgreSQL and PostGIS extensions. 

To populate the database, download the GTFS data CSV files into `data/`
and then run `db/recreate.sh`



ssh zoe@openmbta.org "pg_dump mbta2  -t nextbus_predictions | gzip -c " | gunzip -c | psql mbta2

Include -a if this is repeated 
