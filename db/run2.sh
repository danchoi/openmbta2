#!/bin/bash

# Part 2 of recreate data process. Run run1.sh first.

echo "adding functions"
createlang plpgsql mbta;
psql mbta < db/create_functions.sql

echo Now run run3.sh

