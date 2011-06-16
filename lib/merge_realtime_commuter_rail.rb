require 'database'
require 'pp'

class MergeRealtimeCommuterRail
  # TODO
  def self.available?(route, direction)
    #route = route.split(/\s/)[0] # Red instead of Red Line
    #dataset = DB["select count(*) from view_subway_predictions where line =  ? and direction = ? and arrival_time >= now()", route, direction].first
    #dataset[:count] > 0
  end

  def self.merge(scheduled_trips)
    puts "MERGE REALTIME COMMUTER RAIL"
    stops = scheduled_trips[:stops]
    scheduled_trips[:stops] = stops.inject({}) do |memo, (stop_id, value)|
      stop_name = value[:name]
      value[:sched_arrivals] = value[:next_arrivals].dup
      value[:real_time] = value[:next_arrivals].select {|(time, trip_id)| time != '(scheduled)'}.
        map do |(time, trip_id)|
        val = [time, trip_id]
        if trip_id
          short_trip_id = trip_id.split('-')[-1]
          puts short_trip_id
          res = DB["select route, trip, destination, stop, scheduled, flag, lateness from rt_cr_predictions where flag != 'sch' and trip = ? and stop = ?", short_trip_id, stop_name].first
          if res 
            prediction = res[:scheduled] + ((res[:lateness] || 0).to_i)
            p = prediction.strftime("%H:%M:%S")
            new_time = TimeFormatter.format_time(p) + ' (realtime)'
            val = [new_time, trip_id]
          end
        end
        val
      end
      value[:next_arrivals] = value[:real_time].dup
      memo[stop_id] = value
      memo
    end
    puts scheduled_trips.inspect
    scheduled_trips
  end
end

if __FILE__ == $0
  require 'pp'
end

