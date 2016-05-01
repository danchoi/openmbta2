rm MBTA_GTFS.zip*
rm data/*
wget http://mbta.com/uploadedfiles/MBTA_GTFS.zip
unzip -d data/ MBTA_GTFS.zip
db=${1:-mbta}
db/run1.sh $db
db/run2.sh $db
# db/run3.sh $db  # skip postgis
db/run4.sh $db
psql $db < trips-today.sql


