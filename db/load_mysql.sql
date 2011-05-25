delete from calendar;
load data local infile  '/home/choi/projects/openmbta2/data/calendar.txt'
  into table calendar
  fields terminated by ','
  ignore 1 lines;

delete from trips;
load data local infile  '/home/choi/projects/openmbta2/data/trips.txt'
  into table trips
  fields terminated by ','
  ignore 1 lines;

delete from frequencies;
load data local infile  '/home/choi/projects/openmbta2/data/frequencies.txt'
  into table frequencies
  fields terminated by ','
  ignore 1 lines;

delete from shapes;
load data local infile  '/home/choi/projects/openmbta2/data/shapes.txt'
  into table shapes
  fields terminated by ','
  ignore 1 lines;

delete from stop_times;
load data local infile  '/home/choi/projects/openmbta2/data/stop_times.txt'
  into table stop_times
  fields terminated by ','
  ignore 1 lines;

delete from agency;
load data local infile  '/home/choi/projects/openmbta2/data/agency.txt'
  into table agency
  fields terminated by ','
  ignore 1 lines;

delete from transfers;
load data local infile  '/home/choi/projects/openmbta2/data/transfers.txt'
  into table transfers
  fields terminated by ','
  ignore 1 lines;

delete from calendar_dates;
load data local infile  '/home/choi/projects/openmbta2/data/calendar_dates.txt'
  into table calendar_dates
  fields terminated by ','
  ignore 1 lines;

delete from routes;
load data local infile  '/home/choi/projects/openmbta2/data/routes.txt'
  into table routes
  fields terminated by ','
  ignore 1 lines;

delete from stops;
load data local infile  '/home/choi/projects/openmbta2/data/stops.txt'
  into table stops
  fields terminated by ','
  ignore 1 lines;

