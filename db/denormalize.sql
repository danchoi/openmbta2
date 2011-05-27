/* denormalize trips table */
ALTER table trips ADD COLUMN finished_at varchar(12);

UPDATE trips
SET finished_at  = stLast.arrival_time
 FROM trips t
 INNER JOIN (
     SELECT trip_id, MAX(stop_sequence) maxS
     FROM stop_times
     GROUP BY trip_id
 ) tg ON t.trip_id = tg.trip_id
 JOIN stop_times stLast ON tg.trip_id = stLast.trip_id AND stLast.stop_sequence = tg.maxS;
 



