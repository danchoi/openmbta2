-- create nextbus tables
-- use a postgresql schema 

drop table if exists nextbus_routes cascade;
create table nextbus_routes (
  tag varchar primary key,
  title varchar
);


drop table if exists nextbus_route_configs cascade;
create table nextbus_route_configs (
  routetag varchar,
  stoptag varchar,
  stoptitle varchar
);

create unique index nextbus_route_configs_unique_idx on nextbus_route_configs (routeTag, stopTag);

drop table if exists nextbus_predictions cascade;
create table nextbus_predictions (
  routetag varchar,
  stoptag varchar,
  dirtag varchar,
  arrival_time timestamp,
  triptag varchar,
  vehicle varchar,
  block varchar,
  created timestamp DEFAULT now()
);

create index nextbus_predictions_routetag_idx on nextbus_predictions (routetag);

-- because sometimes the feeds contain dup data.
create unique index nextbus_predictions_unique_idx on nextbus_predictions (routeTag, stoptag, dirtag, arrival_time, triptag, vehicle);


drop VIEW if exists view_bus_predictions;
CREATE VIEW view_bus_predictions AS 
select nextbus_predictions.*, stop_name from nextbus_predictions inner join stops on stops.stop_id = nextbus_predictions.stoptag ;

drop table if exists rt_subway_keys cascade;
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

drop table if exists rt_subway_predictions cascade;
create table rt_subway_predictions (
  line varchar,
  trip_id varchar,
  platform_key varchar,
  information_type varchar,
  arrival_time timestamp,
  route varchar
);

drop view if exists view_subway_predictions;

create VIEW view_subway_predictions 
as select platform_name, keys.stop_id, direction, platform_order, rt_subway_predictions.* from rt_subway_predictions inner join rt_subway_keys keys using(platform_key);

drop table if exists t_alerts cascade;
create table t_alerts (
  title varchar,
  route varchar,
  link varchar,
  description text,
  pubdate timestamp,
  guid varchar primary key
);


drop table if exists rt_cr_predictions cascade;
create table rt_cr_predictions (
  timestamp timestamp,
  route varchar,
  trip varchar,
  destination varchar,
  stop varchar,
  scheduled timestamp,
  flag varchar,
  vehicle int,
  latitude float,
  longitude float,
  heading int,
  speed int,
  lateness int,
  created timestamp DEFAULT now()
);



-- new real time


drop table if exists gtfsrt cascade;
create table gtfsrt (
  route_id varchar,
  trip_id varchar,
  stop_sequence integer,
  stop_id varchar,
  arrival_time timestamp
);


