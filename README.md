# OpenMBTA2

A clean rewrite of OpenMBTA.

## Setup

Assumes PostgreSQL and PostGIS extensions. 

    gem install pg


To populate the database, download the GTFS data CSV files into `data/`
and then run `db/runall.sh`

Then run 

    psql mbta < trips-today.sql





ssh zoe@openmbta.org "pg_dump mbta2  -t nextbus_predictions | gzip -c " | gunzip -c | psql mbta2

Include -a if this is repeated 


Before optimization of transit_routes on Dec 11 2013:

curl http://openmbta.org/routes/Bus 
real    0m2.076s
user    0m0.006s
sys     0m0.004s

After:
real    0m0.884s
user    0m0.006s
sys     0m0.004s


Now to get number 1 trips:

real  0m3.434s
user  0m0.010s
sys 0m0.021s


[choi@sparta openmbta2]$ time ruby -Ilib lib/transit_trips.rb 'Green Line' 0 > out                                                                                                                                                                            

real    0m3.406s
user    0m2.969s
sys     0m0.099s


zoe@li321-67:~/openmbta2$ ruby -Ilib lib/transit_trips.rb 'Green Line' 0  1>/dev/null
select stops.stop_name, st.* from stop_times st
              inner join stops using(stop_id) where trip_id in
             (select trip_id from trips_today where route_coalesced_name = 'Green Line' and direction_id = 0)
             order by stop_id, arrival_time, stop_sequence
calc_next_arrivals took 1.511933737 seconds
make_grid took 3.588673105 seconds
fix_grid_stop_ids took 0.000191765 seconds


Still slow:

ruby -Ilib lib/transit_trips.rb 'Green Line' 0  1>/dev/null
select stops.stop_name, st.* from stop_times st
              inner join stops using(stop_id) where trip_id in
             (select trip_id from trips_today where route_coalesced_name = 'Green Line' and direction_id = 0)
             order by stop_id, arrival_time, stop_sequence
calc_next_arrivals took 2.102558194 seconds
make_grid took 3.095658068 seconds
fix_grid_stop_ids took 0.000181157 seconds
zoe@li321-67:~/openmbta2$ fg


