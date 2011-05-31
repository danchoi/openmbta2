create table rt_subway_keys (
  line varchar,
  platform_key varchar,
  platform_name varchar,
  station_name varchar,
  platform_order int,
  start_of_line boolean,
  end_of_line boolean,
  branch varchar,
  direction varchar,
  stop_id varchar,
  stop_code varchar,
  stop_name varchar,
  stop_desc varchar,
  stop_lat float,
  stop_lon float
);

create table rt_subway_predictions (
  line varchar,
  trip_id varchar,
  platform_key varchar,
  information_type varchar,
  arrival_time timestamp,
  route varchar
);

