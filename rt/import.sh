#!/bin/bash


# cat the input in STDIN

db=${1:-mbta}

psql $db -c "truncate gtfsrt ; COPY gtfsrt FROM STDIN WITH DELIMITER E'\t'"

