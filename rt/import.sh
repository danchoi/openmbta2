#!/bin/bash

db=${1:-mbta}

cat trips.json | jq -rcM '.trip.trip_id as $trip_id | .trip.route_id as $route_id | .stop_time_updates[] | select(.arrival.time != null) | [$route_id, $trip_id,  .stop_sequence, .stop_id, .arrival.time] | @tsv ' |

psql $db -c "COPY gtfsrt FROM STDIN WITH DELIMITER E'\t'"

