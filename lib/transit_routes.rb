require 'sequel'
DB = Sequel.connect 'postgres:///mbta'

class TransitRoutes
  def self.routes(route_types)
    sql = "select * from available_routes(now()) as (route_type smallint, route varchar, direction_id smallint, trips_left bigint) where route_type in ?"
    routes = DB[sql, route_types]
    res = {:data => []}
    routes.all.group_by {|x| x[:route]}.each do |route, directions|
      data = {:route_short_name => route, :headsigns => []}
      directions.each do |d|
        direction_name = d[:direction_id] == 0 ? 'Inbound' : 'Outbound'
        data[:headsigns] << [direction_name, d[:trips_left]] 
      end
      res[:data] << data
    end
  end
end

if __FILE__ == $0
  puts TransitRoutes.routes([ARGV.first.to_i])
end
