truncate calendar;
copy calendar from  '/home/choi/projects/openmbta3/data/calendar.txt'
DELIMITER AS ',' CSV HEADER;

truncate trips;
copy trips from  '/home/choi/projects/openmbta3/data/trips.txt'
DELIMITER AS ',' CSV HEADER;

truncate frequencies;
copy frequencies from  '/home/choi/projects/openmbta3/data/frequencies.txt'
DELIMITER AS ',' CSV HEADER;

truncate shapes;
copy shapes from  '/home/choi/projects/openmbta3/data/shapes.txt'
DELIMITER AS ',' CSV HEADER;

truncate stop_times;
copy stop_times from  '/home/choi/projects/openmbta3/data/stop_times.txt'
DELIMITER AS ',' CSV HEADER;

truncate agency;
copy agency from  '/home/choi/projects/openmbta3/data/agency.txt'
DELIMITER AS ',' CSV HEADER;

truncate transfers;
copy transfers from  '/home/choi/projects/openmbta3/data/transfers.txt'
DELIMITER AS ',' CSV HEADER;

truncate calendar_dates;
copy calendar_dates from  '/home/choi/projects/openmbta3/data/calendar_dates.txt'
DELIMITER AS ',' CSV HEADER;

truncate routes;
copy routes from  '/home/choi/projects/openmbta3/data/routes.txt'
DELIMITER AS ',' CSV HEADER;

truncate stops;
copy stops from  '/home/choi/projects/openmbta3/data/stops.txt'
DELIMITER AS ',' CSV HEADER;

