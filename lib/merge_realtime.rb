require 'database'
require 'realtime_gtfs'
require 'transit_trips'
require 'pp'
require 'time_formatter'
include TimeFormatter 

module MergeRealtime
  class << self
    def merge(scheduled_trips, realtime, type = :bus)

      realtime_data = realtime.results
      scheduled_stops = scheduled_trips[:stops]
      merged_stops = scheduled_stops.inject({}) do |memo, (stop_id, data)|

        mbta_stop_id = data[:mbta_id]

        key = realtime_data.keys.detect {|k| k == mbta_stop_id }
        if ! key.nil?
          realtime_predictions = realtime_data[key].dup
          data[:stoptag] = key.dup
          data[:sched_arrivals] = data[:next_arrivals]
          data[:next_arrivals] = realtime_predictions.map {|x|
            time, trip_id = *x
            time_s = time.strftime("%H:%M:%S")
            [ time_s, trip_id ]
          }.select {|x|
            time_s, trip_id = *x
            time_s > Time.now.strftime('%H:%M:%S')
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
        x = scheduled_stops.detect {|k, v| v[:mbta_id] == i}
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
  #realtime = RealtimeSubway.new('Red Line', 'Northbound')
  #sched_trips = TransitTrips.new('Red Line', 1).result

  realtime = RealtimeGtfs.new ARGV[0], ARGV[1]
  sched_trips = TransitTrips.new(ARGV[0], ARGV[1]).result
  # pp sched_trips
  pp realtime.results
  pp MergeRealtime.merge(sched_trips, realtime, :subway)
end
