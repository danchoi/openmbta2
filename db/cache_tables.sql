drop table if exists trips_today; 
create table trips_today (
  route_id varchar(255),
  service_id varchar(255),
  trip_id varchar(255) primary key,
  trip_headsign varchar(255),
  direction_id smallint,
  block_id varchar(255),
  shape_id varchar(255),
  finished_at varchar(255),
  route_type integer, 
  route_coalesced_name varchar(255)
);
create index trips_today_route_id_idx on trips_today (route_id);
create index trips_today_route_coalesced_name_idx on trips_today (route_coalesced_name); 
create index trips_today_route_type_idx on trips_today (route_type); 
create index trips_today_direction_id_idx on trips_today (direction_id); 

drop table if exists route_directions_today ;
create table route_directions_today (
  route_type integer,
  route varchar,
  direction_id smallint,
  total_trips integer
);
create index route_directions_today_route_type_idx on route_directions_today (route_type); 
create index route_directions_today_route_idx on route_directions_today (route); 
create index route_directions_today_direction_id_idx on route_directions_today (direction_id); 

-- must do this every day
delete from trips_today;
insert into trips_today 
  select route_id,
  service_id, trip_id, trip_headsign, direction_id, block_id, 
  shape_id,
  finished_at,
  route_type,
  case when r.route_type = 3 then r.route_id else   coalesce(nullif(r.route_long_name, ''), nullif(r.route_short_name, '')) end 
  -- coalesce(nullif(r.route_long_name, ''), nullif(r.route_short_name, ''))
  from trips inner join routes r using (route_id) where service_id in (select active_services(adjusted_date(now())) as service_id);

delete from route_directions_today;
insert into route_directions_today 
  select route_type, route_coalesced_name route, direction_id, count(*) as total_trips_today from trips_today  group by route_type, route_coalesced_name, direction_id;

drop table if exists stop_times_today;
create table stop_times_today (
  trip_id varchar(255),
  arrival_time varchar(12),
  departure_time varchar(12),
  stop_id varchar(255),
  stop_sequence int,
  stop_headsign varchar(255),
  pickup_type smallint,
  drop_off_type smallint,
  stop_name varchar,
  PRIMARY KEY (trip_id, stop_sequence)
);
create index stop_times_today_trip_id_idx  on stop_times_today (trip_id);
create index trips_today_trip_id_idx on trips_today (trip_id);

insert into stop_times_today 
  select st.trip_id, st.arrival_time, st.departure_time, st.stop_id, st.stop_sequence, 
    st.stop_headsign, st.pickup_type, st.drop_off_type, stops.stop_name from stop_times st
    inner join stops using (stop_id) 
    inner join trips_today using (trip_id);




