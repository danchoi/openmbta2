require 'database'

class RealtimeSubway

  def self.available?(route, direction)

    route = route.split(/\s/)[0] # Red instead of Red Line
    dataset = DB["select count(*) from view_subway_predictions where line =  ? and direction = ? and arrival_time >= now()", route, direction].first
    dataset[:count] > 0
  end

  def initialize(route, direction)
    @route = route.split(/\s+/)[0]  # a route name
    @direction = direction # Eastbound, etc
  end

  def results
    # direction can be inferred from tail of dirtag
    # 8_80007v0_0
    @stops = Hash.new {|h,k| h[k] = []}
    DB["select * from view_subway_predictions where line = ? and direction = ? and arrival_time >= now()", @route, @direction].each do |x|
      @stops[x[:stop_id]] << [x[:arrival_time], x[:trip_id]]
    end
    @stops = @stops.inject({}) {|memo, (k, v)|
      memo[k] = v.sort_by {|x| x[0]}
      memo
    }
    @stops
  end

  def imminent_stops
    first_stop = {}
    @stops.each do |stop_id, predictions|
      predictions.each do |p|
        time, vehicle = *p
        if first_stop[vehicle].nil? || first_stop[vehicle][:time] > time 
          first_stop[vehicle] = {stop_id: stop_id, time: time}
        end
      end
    end
    first_stop.map {|k, v| v[:stop_id]}.uniq
  end
end

if __FILE__ == $0
  require 'pp'
  x = RealtimeSubway.new('Red Line', 'Northbound')
  pp x.results
  pp x.imminent_stops
end

