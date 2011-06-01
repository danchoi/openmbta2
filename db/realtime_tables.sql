-- create nextbus tables
-- use a postgresql schema 

create table nextbus_routes (
  tag varchar primary key,
  title varchar
);

create table nextbus_route_configs (
  routetag varchar,
  stoptag varchar,
  stoptitle varchar
);

create unique index nextbus_route_configs_unique_idx on nextbus_route_configs (routeTag, stopTag);

create table nextbus_predictions (
  routetag varchar,
  stoptag varchar,
  dirtag varchar,
  arrival_time timestamp,
  triptag varchar,
  vehicle varchar,
  block varchar
);

create index nextbus_predictions_routetag_idx on nextbus_predictions (routetag);

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

create table t_alerts (
  title varchar,
  route varchar,
  link varchar,
  description text,
  pubdate timestamp,
  guid varchar primary key
);


