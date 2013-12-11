require 'database'
require 'direction'
require 'bus_routes'
require 'realtime_bus'

class TransitRoutes
  def self.routes(route_types)
    sql = "select * from available_routes(now()) as (route_type smallint, route varchar, direction_id smallint, trips_left bigint, headsign varchar) where route_type in ? order by route, - direction_id"


    sql = <<SQL

select a.route_type, a.route, a.direction_id, 
coalesce(b.trips_left, 0), b.headsign from 
  (select r.route_type, coalesce(nullif(r.route_long_name, ''), nullif(r.route_short_name, '')) route, trips_today.direction_id
    from 
    trips_today 
    inner join routes r using (route_id)
    group by r.route_type, route, trips_today.direction_id) a
left outer join 
  (select r.route_type, coalesce(nullif(r.route_long_name, ''), nullif(r.route_short_name, '')) route, trips_today.direction_id,
    count(*) as trips_left,
    array_to_string(array_agg(trip_headsign), ';') as headsign
    from trips_today 
    inner join routes r using (route_id) 
    where trips_today.finished_at > adjusted_time(now())
    group by r.route_type, route, trips_today.direction_id) b
    on (a.route_type = b.route_type and a.route = b.route and a.direction_id = b.direction_id)
where a.route_type in ?
order by route_type, route, - a.direction_id ;
SQL

    routes = DB[sql, route_types]

    $stderr.puts( DB[sql, route_types].sql )
    exit

    res = {:data => []}
    routes.all.group_by {|x| x[:route]}.each do |route, directions|
      data = {:route_short_name => BusRoutes.abbreviate(route), :headsigns => []}
      directions.each do |d|
        
        headsigns = (d[:headsign] || '').split(';')
        headsign = if route!= 'Green Line'
                     most_common_value(headsigns)
                   end


        direction_name = Direction.id2name(d[:direction_id], route_types, route) 
        if headsign
          direction_name += ": " + headsign
        end
        data[:headsigns] << [direction_name, d[:trips_left]] 
        # If subway, the v3 client expects three elements.
        if !([0, 1] & route_types).empty?
          data[:headsigns][-1] << route
        # if realtime bus data is available, flag the route as realtime-data-available
        elsif route_types == [3] && RealtimeBus.available?(route, d[:direction_id])
          data[:headsigns][-1] << "+ realtime data"
        end 
      end
      res[:data] << data
    end
    # sort bus routes correctly
    res[:data] = res[:data].sort_by {|route| 
      name = route[:route_short_name]
      if name =~ /^\d+/
        "%.5d" % name[/^\d+/, 0]  # front-pad with zeros to sort correctly
      else
        name
      end
    }
    res
  end

  def self.most_common_value(a)
    return nil if a.empty?
    # strip train numbers for commuter rails
    a.map {|e| 
      e.gsub(/\s*\([^)]+\)/, '')
    }.group_by do |e|
      e
    end.values.max_by(&:size).first
  end
end

if __FILE__ == $0
  require 'pp'
  pp TransitRoutes.routes([ARGV.first.to_i])
end
