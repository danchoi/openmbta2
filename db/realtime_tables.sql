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

CREATE VIEW view_bus_predictions AS 
select nextbus_predictions.*, stop_name from nextbus_predictions inner join stops on stops.stop_id = nextbus_predictions.stoptag ;

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

create VIEW view_subway_predictions 
as select platform_name, keys.stop_id, direction, platform_order, rt_subway_predictions.* from rt_subway_predictions inner join rt_subway_keys keys using(platform_key);

create table t_alerts (
  title varchar,
  route varchar,
  link varchar,
  description text,
  pubdate timestamp,
  guid varchar primary key
);


