#!/bin/bash


# cat the input in STDIN

db=${1:-mbta}

jq -rcM '.trip.trip_id as $trip_id | .trip.route_id as $route_id | .stop_time_updates[] | 
select(.arrival.time != null) | 
[$route_id, $trip_id,  .stop_sequence, .stop_id, .arrival.time ] | @tsv ' | 
awk -F $'\t' '
  BEGIN { OFS="\t" }
  {
    cmd = "date --date=@"$5 " +%FT%H:%M:%S"
    cmd | getline d
    $5= d
    print $0
    close(cmd, "from")
  }
' | psql $db -c "truncate gtfsrt ; COPY gtfsrt FROM STDIN WITH DELIMITER E'\t'"

