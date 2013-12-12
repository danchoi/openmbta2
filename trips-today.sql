delete from trips_today;
insert into trips_today select route_id,
  service_id, trip_id, trip_headsign, direction_id, block_id, 
  shape_id,
  finished_at,
  route_type,
  coalesce(nullif(r.route_long_name, ''), nullif(r.route_short_name, ''))
  from trips inner join routes r using (route_id) where service_id in (select active_services(adjusted_date(now())) as service_id);

delete from route_directions_today;
insert into route_directions_today 
  select route_type, route_coalesced_name route, direction_id, count(*) as total_trips_today from trips_today  group by route_type, route_coalesced_name, direction_id;

