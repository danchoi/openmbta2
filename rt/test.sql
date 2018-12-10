select gtfsrt.route_id, 
gtfsrt.trip_id, 
gtfsrt.stop_sequence,
gtfsrt.stop_id,
gtfsrt.arrival_time,
-- if trip is ADDED, we must get the direction from the stop
coalesce(trips.direction_id, 
  (select direction_id from trips inner join stop_times using (trip_id) where stop_id = gtfsrt.stop_id  limit 1)
) direction_id,
to_char(to_timestamp(gtfsrt.arrival_time), 'HH24:MI') as fmtime
from gtfsrt left join trips using (trip_id);  

