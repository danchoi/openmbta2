select gtfsrt.*, 
-- if trip is ADDED, we must get the direction from the stop
coalesce(trips.direction_id, (select direction_id from trips inner join stop_times using (trip_id) where stop_id = gtfsrt.stop_id  limit 1))
from gtfsrt left join trips using (trip_id);  

