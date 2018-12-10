require 'database'

class RealtimeGtfs

  SQL = <<END
select 
gtfsrt.route_id, 
gtfsrt.trip_id, 
gtfsrt.stop_sequence,
gtfsrt.stop_id,
gtfsrt.arrival_time,
-- if trip is ADDED, we must get the direction from the stop
coalesce(trips.direction_id, 
  (select direction_id from trips inner join stop_times using (trip_id) where stop_id = gtfsrt.stop_id  limit 1)
) direction_id,
to_char(gtfsrt.arrival_time, 'HH24:MI') as fmtime
from gtfsrt left join trips using (trip_id)
where gtfsrt.route_id = ? and direction_id = ?
END


  def self.available?(route, direction_id)
    dataset = DB["select count(*) from nextbus_predictions inner join routes on (trim(leading '0' from  split_part(routes.route_id, '-', 1)) = nextbus_predictions.routetag)     
      where (case when routes.route_type = 3 then coalesce(routes.route_short_name, routes.route_id) else  coalesce(nullif(routes.route_long_name, ''), nullif(routes.route_short_name, '')) end ) = ?
        and split_part(dirtag, '_', 2) = ? and arrival_time > now()", route, direction_id.to_s].first
    dataset[:count] > 0
  end


  def initialize(route, direction_id)
    @route = route # a route name
    @route_id = find_route_id
    @direction_id = direction_id # let direction by 0 or 1
  end

  def find_route_id
    r = DB["select r.route_id from routes r 
            where r.route_id = ? or (case when r.route_type = 3 then coalesce(r.route_short_name, r.route_id) else coalesce(nullif(r.route_long_name, ''), nullif(r.route_short_name, '')) end) = ?
            ", @route, @route].to_a.first
    r && r[:route_id]
  end

  def results
    @stops = Hash.new {|h,k| h[k] = []}
    DB[SQL, @route_id, @direction_id].each { |x|
      item = [x[:arrival_time], x[:trip_id]] # use trip_id as vehicle id
      # because the above SQL query can return dup routes (in service at different times)
      if @stops[x[:stop_id]] &&  @stops[x[:stop_id]].detect {|y| y == item }
        next
      end
      @stops[x[:stop_id]] << item
    }
    @stops
  end

  def imminent_stops
    first_stop = {}
    @stops.each do |stop_id, predictions|
      predictions.each do |p|
        time, trip_id = *p
        if first_stop[trip_id].nil? || first_stop[trip_id][:time] > time 
          first_stop[trip_id] = {stop_id: stop_id, time: time}
        end
      end
    end
    first_stop.map {|k, v| v[:stop_id]}.uniq
  end
end

if __FILE__ == $0
  require 'pp'
  route = ARGV[0]
  dir = ARGV[1].to_i
  x = RealtimeGtfs.new route, dir
  pp x.results
  pp x.imminent_stops
end
