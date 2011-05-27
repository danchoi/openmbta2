require 'sequel'
DB = Sequel.connect 'postgres:///mbta'
# don't put semicolon at the end of sequel query
require 'yaml'
route = '1'
query = <<QUERY
select stops.stop_name, stops.stop_code, st.* from stop_times_today('#{route}', 1) st join stops using(stop_id)
QUERY

trips = Hash.new {|hash, key| hash[key] = []}

DB[query].each do |row|
  stopping = { 
    arrival_time: row[:arrival_time], 
    stop_name: row[:stop_name], 
    stop_sequence: row[:stop_sequence],
    stop_id: row[:stop_id]
  }
  trips[row[:trip_id]] << stopping
end

puts '-' * 80

#puts trips.to_yaml

trips.each do |k, v|
  puts
  puts "trip: #{k}"
  puts v.sort_by {|x| x[:stop_sequence]}.inspect
end

def make_grid(trips)
  puts "trips: %s" % trips.size
  grid = [] 
  first_stops = []
  trips.each.with_index do |x, col|
    trip_id = x[0]
    stoppings = x[1]
    next_grid_row = 0
    stoppings.each_with_index do |stopping, i|
      stop = stopping[:stop_name]
      time = stopping[:arrival_time]
      pos = stopping[:stop_sequence]
      if i == 0 && !first_stops.include?(stop)
        first_stops << stop
        #puts "FIRST STOPS"
        #puts first_stops.inspect
      end
      stop_row = grid.detect {|x| x.is_a?(Hash) && x[:stop] == stop}
      if stop_row
        stop_row[:times][col] = time
        next_grid_row = grid.index(stop_row) + 1
      else
        values = Array.new(trips.size)
        values[col] = time
        stop_row = {:stop => stop, :times => values}
        grid.insert(next_grid_row, stop_row)
        next_grid_row += 1
      end
    end
  end
  puts grid.inspect
  grid
end
puts '-' * 80

make_grid(trips)
