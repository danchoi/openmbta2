#!/bin/bash
set -x
psql $DB -c "truncate gtfsrt"
rt/import.sh $DB < trips.tsv
