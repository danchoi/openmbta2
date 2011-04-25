select trips.*,

  (select stop_name 
    from stops 
    inner join stop_times
    on stops.stop_id = stop_times.stop_id
    where stop_times.trip_id = trips.trip_id
    order by stop_sequence asc
    limit 1) origin
  ,
  (select stop_name 
    from stops 
    inner join stop_times
    on stops.stop_id = stop_times.stop_id
    where stop_times.trip_id = trips.trip_id
    order by stop_sequence desc
    limit 1) destination
  ,
  (select arrival_time
    from stop_times
    where stop_times.trip_id = trips.trip_id
    order by stop_sequence asc
    limit 1) starts
  ,
  (select arrival_time
    from stop_times
    where stop_times.trip_id = trips.trip_id
    order by stop_sequence desc
    limit 1) ends

from trips
where trips.route_id = 'CR-Providence'
order by ends asc
\G




/* this is slow; try denorm3 */
update trips
  set origin = 
  (select stop_name 
    from stops 
    inner join stop_times
    on stops.stop_id = stop_times.stop_id
    where stop_times.trip_id = trips.trip_id
    order by stop_sequence asc
    limit 1) 
  ,
  destination = 
  (select stop_name 
    from stops 
    inner join stop_times
    on stops.stop_id = stop_times.stop_id
    where stop_times.trip_id = trips.trip_id
    order by stop_sequence desc
    limit 1)
  ,
  starts = 
  (select arrival_time
    from stop_times
    where stop_times.trip_id = trips.trip_id
    order by stop_sequence asc
    limit 1) 
  ,
  ends = 
  (select arrival_time
    from stop_times
    where stop_times.trip_id = trips.trip_id
    order by stop_sequence desc
    limit 1)
;

