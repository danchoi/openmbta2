create table agency (
  agency_id varchar(10) primary key,
  agency_name varchar(255),
  agency_url varchar(255),
  agency_timezone varchar(255),
  agency_lang varchar(255),
  agency_phone varchar(255)
) ;

create table calendar (
  service_id varchar(255) primary key,
  service_days bool[],
  start_date date,
  end_date date
) ;

create table calendar_dates (
  service_id varchar(255),
  date date,
  exception_type varchar(10)
) ;

create table frequencies (
  trip_id varchar(255),
  start_time varchar(12),
  end_time varchar(12),
  headway_secs int
) ;

create table routes (
  route_id varchar(255) PRIMARY KEY,
  agency_id varchar(10),
  route_short_name varchar(255),
  route_long_name varchar(255),
  route_desc varchar(255),
  route_type smallint,
  route_url varchar(255),
  route_color varchar(255),
  route_text_color varchar(255),
  route_sort_order int
) ;

create table shapes (
  shape_id varchar(255),
  shape_pt_lat float,
  shape_pt_lon float,
  shape_pt_sequence int,
  shape_dist_traveled float
) ;

create table stop_times (
  trip_id varchar(255),
  arrival_time varchar(12),
  departure_time varchar(12),
  stop_id varchar(255),
  stop_sequence int,
  stop_headsign varchar(255),
  pickup_type smallint,
  drop_off_type smallint,
  timepoint smallint default 0,
  something  smallint default 0,
  PRIMARY KEY (trip_id, stop_sequence)
) ;

/* alter table stop_times add index trip_id (trip_id(5)); */

create table stops (
  stop_id varchar(255) PRIMARY KEY,
  stop_code varchar(255),
  stop_name varchar(255),
  platform_code varchar(255),
  platform_name varchar(255),
  stop_desc varchar(255),
  stop_lat float,
  stop_lon float,
  stop_address varchar(255),
  zone_id varchar(255), /* what is this? not sure of type */
  stop_url varchar(255),
  level_id varchar(255),
  location_type smallint,
  parent_station varchar(255),
  wheelchair_boarding smallint
) ;

create table transfers (
  from_stop_id varchar(255),
  to_stop_id varchar(255),
  transfer_type smallint,
  min_transfer_time int
);

create table trips (
  route_id varchar(255),
  service_id varchar(255),
  trip_id varchar(255) primary key,
  trip_headsign varchar(255),
  trip_short_name varchar(255),
  direction_id smallint,
  block_id varchar(255),
  shape_id varchar(255),
  wheelchair_accessible smallint,
  something varchar(10)
) ;



