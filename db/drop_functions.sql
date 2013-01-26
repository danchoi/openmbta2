drop FUNCTION coalesce2(varchar, varchar); 
drop FUNCTION active_services(date); 
drop FUNCTION active_trips(date);
drop FUNCTION adjusted_time(x timestamp with time zone);
drop FUNCTION adjusted_date(x timestamp with time zone); 
drop FUNCTION available_routes(timestamp with time zone);
drop FUNCTION route_trips_today(varchar, int);
drop FUNCTION stop_times_today(varchar, int);
drop VIEW view_available_routes; 
drop FUNCTION available_routes3(timestamp with time zone);
drop FUNCTION route_type_to_string(int);
drop FUNCTION route_stops_today(varchar, int);
drop FUNCTION trips_for_route_direction_stops(varchar, int, varchar, varchar);

