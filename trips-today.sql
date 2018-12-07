delete from trips_today;
insert into trips_today 
  select route_id,
  service_id, trip_id, trip_headsign, direction_id, block_id, 
  shape_id,
  finished_at,
  route_type,
  (case when r.route_type = 3 then coalesce(r.route_short_name, r.route_id) else  coalesce(nullif(r.route_long_name, ''), nullif(r.route_short_name, '')) end) 
  from trips inner join routes r using (route_id) where service_id in (select active_services(adjusted_date(now())) as service_id);

delete from route_directions_today;
insert into route_directions_today 
  select route_type, route_coalesced_name route, direction_id, count(*) as total_trips_today from trips_today  group by route_type, route_coalesced_name, direction_id;

delete from stop_times_today ;
insert into stop_times_today 
  select st.trip_id, st.arrival_time, st.departure_time, st.stop_id, st.stop_sequence, 
    st.stop_headsign, st.pickup_type, st.drop_off_type, stops.stop_name from stop_times st
    inner join stops using (stop_id) 
    inner join trips_today using (trip_id);



