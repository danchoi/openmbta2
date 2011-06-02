require 'database'

class RealtimeBus

  # We should put the common SQL shared by :available? and :results in a function or view
  #
  def self.available?(route, direction_id)
    dataset = DB["select count(*) from nextbus_predictions inner join routes on (trim(leading '0' from  split_part(routes.route_id, '-', 1)) = nextbus_predictions.routetag)     
      where coalesce(nullif(routes.route_long_name, ''), nullif(routes.route_short_name, '')) = ? and split_part(dirtag, '_', 3) = ? and arrival_time > now()", route, direction_id.to_s].first
    dataset[:count] > 0
  end


  def initialize(route, direction_id)
    @route = route # a route name
    @direction_id = direction_id # let direction by 0 or 1
  end

  def results
    # direction can be inferred from tail of dirtag
    # 8_80007v0_0
    @stops = Hash.new {|h,k| h[k] = []}
    DB["select * from nextbus_predictions 
      inner join routes on (trim(leading '0' from  split_part(routes.route_id, '-', 1)) = nextbus_predictions.routetag)     
      where coalesce(nullif(routes.route_long_name, ''), nullif(routes.route_short_name, '')) = ? 
      and split_part(dirtag, '_', 3) = ?", @route, @direction_id.to_s].each do |x|
      @stops[x[:stoptag]] << [x[:arrival_time], x[:vehicle]]
    end
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
  x = RealtimeBus.new('1', 1)
  pp x.results
  pp x.imminent_stops
end
