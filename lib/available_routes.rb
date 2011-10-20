require 'yaml'
require 'database'

# make sure this view exists:

# create view view_available_routes as select * from available_routes(now()) as (route_type smallint, route varchar, direction_id smallint, trips_left bigint, headsign varchar)

x = DB["select * from view_available_routes"].to_a.group_by {|x|
  x[:route_type]
}.map {|(group, values)|
  {'group' => group, 'routes' => values.map {|x| x.delete(:route_type); x }}
}

puts({'modes' => x}.to_yaml)
puts '---' # for mustache

