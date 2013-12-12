delete from trips_today;
insert into trips_today select * from trips where service_id in (select active_services(adjusted_date(now())) as service_id);
delete from route_directions_today;
insert into route_directions_today 
  select route_type, route_coalesced_name route, direction_id, count(*) as total_trips_today from trips_today  group by route_type, route_coalesced_name, direction_id;

