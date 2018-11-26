#!/bin/bash
set -e
data/routes.txt: MBTA_GTFS.zip
	unzip -d data/ $<

MBTA_GTFS.zip:
	curl -L https://cdn.mbta.com/MBTA_GTFS.zip > $@



all:
	db/runall.sh
