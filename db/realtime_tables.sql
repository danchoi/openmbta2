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

create table t_alerts (
  title varchar,
  link varchar,
  description text,
  pubdate timestamp,
  guid varchar primary key
);

