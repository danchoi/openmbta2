#!/bin/bash

echo make data/routes.txt

db=${1:-mbta}

db/run1.sh $db

#ruby -Ilib lib/prepare_realtime_tables.rb $db

psql $db < trips-today.sql


