require 'database'
require 'direction'
require 'bus_routes'
require 'realtime_bus'

require 'pp'

class TransitRoutes

  def self.routes(route_types)
    @key = "ROUTES,#{route_types.join(',')}"
    @ttl = 60
    if (res = MEMCACHED.get(@key))
      return res
    end

    sql = <<SQL

select rdt.route_type, rdt.route, rdt.direction_id, coalesce(count(tt.finished_at), 0) trips_left, array_to_string(array_agg(distinct tt.trip_headsign), ';') headsign
  from route_directions_today rdt
  left outer join 
    trips_today tt on 
    (tt.route_type = rdt.route_type and tt.route_coalesced_name = rdt.route and tt.direction_id = rdt.direction_id and tt.finished_at > adjusted_time(now())) 
    where tt.route_type in ?
  group by rdt.route_type, rdt.route, rdt.direction_id
  order by rdt.route_type, rdt.route, - rdt.direction_id ;
SQL

    routes = DB[sql, route_types]

    # $stderr.puts( DB[sql, route_types].sql )
    # exit
    # time this far for route type 3 0.7s

    res = {:data => []}
    
    # $stderr.puts(routes.all.group_by {|x| x[:route]})

    routes.all.group_by {|x| x[:route]}.each do |route, directions|
      data = {:route_short_name => BusRoutes.abbreviate(route), :headsigns => []}
      directions.each do |d|
        
        headsigns = (d[:headsign] || '').split(';')
        headsign = if route != 'Green Line'
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
    MEMCACHED.set(@key, res, @ttl)
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
