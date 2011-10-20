-- use this to shorten coalescing with ifnull
CREATE FUNCTION coalesce2(varchar, varchar) RETURNS varchar AS $$ select
coalesce(nullif($1, ''), nullif($2, '')); $$ LANGUAGE SQL;


CREATE FUNCTION active_services(date) RETURNS setof varchar AS $$
select service_id from (
  select service_id from calendar 
  where service_days[(select to_char($1, 'ID'))::int] = true and start_date <= $1 and end_date >= $1
  UNION
  select service_id from calendar_dates 
  where exception_type = 'add' and date = $1
) services
EXCEPT 
  select service_id from calendar_dates 
  where exception_type = 'remove' and date = $1;
$$ language sql;

CREATE FUNCTION active_trips(date) RETURNS SETOF trips AS $$
select * from trips where service_id in (select active_services($1) as service_id);
$$ LANGUAGE SQL;

CREATE FUNCTION adjusted_time(x timestamp with time zone) RETURNS character(8) AS $$
DECLARE
  h integer;
  m integer;
  s  integer;
BEGIN
  h := extract(hour from x);
  m := extract(minutes from x);
  IF h  < 4 THEN 
    h := h + 24;
  END IF;
  RETURN lpad(h::text, 2, '0') || ':' || m || ':00';
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION adjusted_date(x timestamp with time zone) RETURNS date AS $$
BEGIN
  IF extract(hour from x) < 4 THEN 
    RETURN date( x - interval '24 hours' );    
  ELSE 
    RETURN date(x);
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION available_routes(timestamp with time zone) RETURNS setof record AS $$
select a.route_type, a.route, a.direction_id, 
coalesce(b.trips_left, 0), b.headsign from 
(select r.route_type, coalesce(nullif(r.route_long_name, ''), nullif(r.route_short_name, '')) route, trips.direction_id
from active_trips(adjusted_date($1)) as trips inner join routes r using (route_id)
group by r.route_type, route, trips.direction_id) a
left outer join (select r.route_type, coalesce(nullif(r.route_long_name, ''), nullif(r.route_short_name, '')) route, trips.direction_id,
  count(*) as trips_left,
  array_to_string(array_agg(trip_headsign), ';') as headsign
  from active_trips(adjusted_date($1)) as trips inner join routes r using (route_id) 
  where trips.finished_at > adjusted_time($1)
  group by r.route_type, route, trips.direction_id) b
  on (a.route_type = b.route_type and a.route = b.route and a.direction_id = b.direction_id)
  order by route_type, route, direction_id;
$$ language sql;



-- used by transit_trips.rb

CREATE FUNCTION stop_times_today(varchar, int) RETURNS SETOF stop_times AS $$
select * from stop_times st where trip_id in 
(select trip_id from route_trips_today($1, $2))
order by stop_id, arrival_time, stop_sequence;
$$ LANGUAGE SQL;

CREATE FUNCTION route_trips_today(varchar, int) RETURNS SETOF trips AS $$
select trips.* 
from active_trips(date(now())) as trips 
inner join routes r using (route_id) 
where trips.direction_id = $2 and coalesce(nullif(r.route_long_name, ''), nullif(r.route_short_name, '')) = $1;
$$ LANGUAGE SQL;


-- available_routes3() : no headsigns or directions

CREATE OR REPLACE FUNCTION route_type_to_string(int) RETURNS VARCHAR as $$
select case 
when $1=0 then 'subway'
when $1=1 then 'subway'
when $1=2 then 'commuter rail'
when $1=3 then 'bus'
when $1=4 then 'boat'
else 'undefined' 
end;
$$ language sql;


CREATE OR REPLACE FUNCTION available_routes3(timestamp with time zone) RETURNS setof record AS $$
select route_type_to_string(a.route_type) as mode, a.route, coalesce(b.trips_left, 0) from 
  -- a
  (select r.route_type, coalesce(nullif(r.route_long_name, ''), nullif(r.route_short_name, '')) route from active_trips(adjusted_date($1)) as trips 
    inner join routes r using (route_id) group by r.route_type, route) a
left outer join
  -- b
  (select r.route_type, coalesce(nullif(r.route_long_name, ''), nullif(r.route_short_name, '')) route, 
    count(*) as trips_left
    from active_trips(adjusted_date($1)) as trips inner join routes r using (route_id) 
    where trips.finished_at > adjusted_time($1)
    group by r.route_type, route) b
  -- back to main
  on (a.route_type = b.route_type and a.route = b.route)
  order by a.route_type, route;
$$ language sql;

CREATE OR REPLACE VIEW view_available_routes as select * from available_routes3(now()) as (route_type varchar, route varchar, trips_left bigint);


-- used by dynamic html version

CREATE OR REPLACE FUNCTION route_stops_today(varchar, int) RETURNS SETOF record AS $$
select stops.stop_id, stop_code, stop_name, stop_lat, stop_lon, stop_times.trip_id, arrival_time, stop_sequence from stops inner join stop_times using(stop_id) 
inner join trips using(trip_id) where trip_id in 
(select trip_id from route_trips_today($1, $2))
order by stop_sequence, stop_id;
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION trips_for_route_direction_stops(varchar, int, varchar, varchar) RETURNS setof record AS $$
select
  trips.trip_id,
  -- stop 1
    st1.arrival_time s1_arrives,
    st1.stop_sequence s1_seq,
  -- stop 2
    st2.arrival_time s2_arrives,
    st2.stop_sequence s2_seq
from trips
  inner join stop_times st1 using (trip_id)
  inner join stop_times st2 using (trip_id)
-- maybe later make the time variable
where trips.trip_id in (select trip_id from route_trips_today($1, $2))
  and st1.stop_id = $3
  and st2.stop_id = $4
  order by st1.arrival_time;
$$ LANGUAGE SQL;

Rubyfied

[{:trip_id=>"15489385", :s1_arrives=>"05:30:00", :s1_seq=>2, :s2_arrives=>"05:38:00", :s2_seq=>6}, {:trip_id=>"15489161", :s1_arrives=>"05:37:00", :s1_seq=>2, :s2_arrives=>"05:45:00", :s2_seq=>6}, {:trip_id=>"15489178", :s1_arrives=>"05:43:00", :s1_seq=>2, :s2_arrives=>"05:51:00", :s2_seq=>6}, {:trip_id=>"15489234", :s1_arrives=>"05:50:00", :s1_seq=>2, :s2_arrives=>"05:58:00", :s2_seq=>6}, {:trip_id=>"15489242", :s1_arrives=>"05:56:


