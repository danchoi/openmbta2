require 'database'
require 'realtime_bus'
require 'transit_trips'
require 'pp'
require 'time_formatter'
include TimeFormatter 

module MergeRealtime
  class << self
    def merge_bus(scheduled_trips, realtimebus)
      realtime_data = realtimebus.results
      scheduled_stops = scheduled_trips[:stops]
      merged_stops = scheduled_stops.inject({}) do |memo, (stop_id, data)|
        mbta_stop_id = data[:mbta_id]
        key = realtime_data.keys.detect {|key|
          key.split('_')[0] == mbta_stop_id
        }
        realtime_predictions = realtime_data[key]
        data[:stoptag] = key
        data[:sched_arrivals] = data[:next_arrivals]
        data[:next_arrivals] = realtime_predictions.map {|x|
          time, trip_id = *x
          time_s = time.strftime("%I:%M:%S")
          [ format_time(time_s), trip_id ]
        }[0,3] + [["(realtime)", nil]]
        data
        memo[stop_id] = data
        memo
      end
      scheduled_trips[:stops] = merged_stops
      scheduled_trips[:scheduled_imminent_stop_ids] = scheduled_trips[:imminent_stop_ids] 
      scheduled_trips[:imminent_stop_ids] = realtimebus.imminent_stops.map {|i|
        x = scheduled_stops.detect {|k, v| v[:mbta_id] == i}
        x && x[0]
      }
      scheduled_trips
    end

  end
end

if __FILE__ == $0
  require 'pp'
  realtimebus = RealtimeBus.new('1', 1)
  sched_trips = TransitTrips.new('1', 1).result
  pp MergeRealtime.merge_bus(sched_trips, realtimebus)
end
