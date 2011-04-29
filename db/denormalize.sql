/* denormalize trips table */
ALTER table trips ADD COLUMN origin varchar(255);
ALTER table trips ADD COLUMN destination varchar(255);
ALTER table trips ADD COLUMN starts varchar(10);
ALTER table trips ADD COLUMN ends varchar(10);

UPDATE trips
 SET origin = stFirstStop.stop_name,
     destination = stLastStop.stop_name,
     starts = stFirst.arrival_time,
     ends = stLast.arrival_time
 FROM trips t
 INNER JOIN (
     SELECT trip_id, MIN(stop_sequence) minS, MAX(stop_sequence) maxS
     FROM stop_times
     GROUP BY trip_id
 ) tg ON t.trip_id = tg.trip_id
 JOIN stop_times stFirst ON tg.trip_id = stFirst.trip_id AND stFirst.stop_sequence = tg.minS
 JOIN stop_times stLast ON tg.trip_id = stLast.trip_id AND stLast.stop_sequence = tg.maxS
 JOIN stops stFirstStop ON stFirst.stop_id = stFirstStop.stop_id
 JOIN stops stLastStop ON stLast.stop_id = stLastStop.stop_id;


