require 'database'
require 'realtime_bus'
require 'realtime_subway'
require 'transit_trips'
require 'pp'
require 'time_formatter'
include TimeFormatter 

module MergeRealtime
  class << self
    def merge(scheduled_trips, realtime, type = :bus)
      stop_id_key =  case type
                     when :bus
                       :mbta_id
                     when :subway
                       :parent_stop_mbta_id
                     else
                       raise "No mbta_stop_id"
                     end
      realtime_data = realtime.results
      scheduled_stops = scheduled_trips[:stops]
      merged_stops = scheduled_stops.inject({}) do |memo, (stop_id, data)|

        mbta_stop_id = data[stop_id_key]

        key = realtime_data.keys.detect {|k|
          k.split('_')[0] == mbta_stop_id
        }
        if key.nil?

        else
          realtime_predictions = realtime_data[key].dup
          data[:stoptag] = key.dup
          data[:sched_arrivals] = data[:next_arrivals]
          data[:next_arrivals] = realtime_predictions.map {|x|
            time, trip_id = *x
            time_s = time.strftime("%I:%M:%S")
            [ time_s, trip_id ]
          }.select {|x|
            time_s, trip_id = *x
            time_s > Time.now.strftime('%I:%M%S')
          }.map {|x|
            time_s, trip_id = *x
            [format_time(time_s), trip_id]
          }[0,3] + [["(realtime)", nil]]
          if data[:next_arrivals].size == 1
            data[:next_arrivals] = data[:sched_arrivals]
          end
        end
        memo[stop_id] = data
        memo
      end
      scheduled_trips[:stops] = merged_stops
      scheduled_trips[:scheduled_imminent_stop_ids] = scheduled_trips[:imminent_stop_ids] 
      scheduled_trips[:imminent_stop_ids] = realtime.imminent_stops.map {|i|
        x = scheduled_stops.detect {|k, v| v[stop_id_key] == i}
        x && x[0]
      }
      scheduled_trips
    end

  end
end

if __FILE__ == $0
  require 'pp'
  #realtime = RealtimeBus.new('1', 1)
  #sched_trips = TransitTrips.new('1', 1).result
  realtime = RealtimeSubway.new('Red Line', 'Northbound')
  sched_trips = TransitTrips.new('Red Line', 1).result
  pp realtime.results
  pp MergeRealtime.merge(sched_trips, realtime, :subway)
end
