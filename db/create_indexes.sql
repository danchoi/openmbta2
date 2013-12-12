
create index stop_times_arrival_time on stop_times (arrival_time);
CREATE INDEX stop_times_trip_id_idx ON stop_times(trip_id);
CREATE INDEX stop_times_stop_id_idx ON stop_times(stop_id);
CREATE INDEX trips_route_id_idx ON trips(route_id);
