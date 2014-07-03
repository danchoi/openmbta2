db=${1:-mbta}
db/run1.sh $db
db/run2.sh $db
db/run3.sh $db
db/run4.sh $db
psql $db < trips-today.sql
