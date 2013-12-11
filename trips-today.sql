delete from trips_today;
insert into trips_today select * from trips where service_id in (select active_services(adjusted_date(now())) as service_id);

