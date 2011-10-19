
require 'database'

# make sure this view exists:

# create view view_available_routes as select * from available_routes(now()) as (route_type smallint, route varchar, direction_id smallint, trips_left bigint, headsign varchar)

puts DB["select * from view_available_routes"].to_a
