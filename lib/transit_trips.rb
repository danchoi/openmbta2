require 'sequel'
DB = Sequel.connect 'postgres:///mbta'
# don't put semicolon at the end of sequel query
require 'yaml'

class TransitTrips
  attr :trips, :grid
  def initialize(route, direction_id)
    @route = route # a route name
    @direction_id = direction_id # let direction by 0 or 1
    @trips = Hash.new {|hash, key| hash[key] = []}
    calc_next_arrivals
    make_grid
  end

  def calc_next_arrivals
    query = "select stops.stop_name, stops.stop_code, st.* from stop_times_today(?, ?) st join stops using(stop_id)"
    DB[query, @route, @direction_id].each do |row|
      stopping = { 
        arrival_time: row[:arrival_time], 
        stop_name: row[:stop_name], 
        stop_sequence: row[:stop_sequence],
        stop_id: row[:stop_id]
      }
      @trips[row[:trip_id]] << stopping
    end
  end

  def make_grid
    @grid = [] 
    first_stops = []
    @trips.each.with_index do |x, col|
      trip_id = x[0] # key
      stoppings = x[1].sort_by {|stopping| stopping[:stop_sequence]} # x[1] is values
      next_grid_row = 0
      stoppings.each_with_index do |stopping, i|
        stop = stopping[:stop_name]
        # TODO mark time if past or future
        time = format_and_flag_time stopping[:arrival_time]
        pos = stopping[:stop_sequence]
        if i == 0 && !first_stops.include?(stop)
          first_stops << stop
          #puts "FIRST STOPS"
          #puts first_stops.inspect
        end
        stop_row = @grid.detect {|x| x.is_a?(Hash) && x[:stop] == stop}
        if stop_row
          stop_row[:times][col] = time
          next_grid_row = @grid.index(stop_row) + 1
        else
          values = Array.new(@trips.size)
          values[col] = time
          stop_row = {:stop => stop, :times => values}
          @grid.insert(next_grid_row, stop_row)
          next_grid_row += 1
        end
      end
    end
  end

  private

  def format_and_flag_time(time) # time is HH:MM:SS
    return unless time
    # strip off seconds
    hour, min = *time.split(':')[0,2]
    time_string = time[/^(\d{2}:\d{2})/, 1]
    now_hour = Time.now.hour

    if now_hour < 4 # 24 hour clock, 1 am
      now_hour += + 24
    end
    time_now = "%.2d:.2d" % [now_hour, Time.now.min]

    if time_string < time_now
      [format_time(time), -1]
    else
      [format_time(time), 1]
    end
  end

  def format_time(time)
    # "%H:%M:%S" -> 12 hour clock with am or pm
    hour, min = time.split(":")[0,2]
    hour = hour.to_i
    suffix = 'a'
    if hour > 24
      hour = hour - 24
    elsif hour == 12
      suffix = 'p'
    elsif hour == 24
      hour = 12
      suffix = 'a'
    elsif hour > 12
      hour = hour - 12
      suffix = 'p'
    elsif hour == 0
      suffix = 'a'
      hour = 12 # midnight
    end
    "#{hour}:#{min}#{suffix}"
  end

end


if __FILE__ == $0
  route = ARGV.first || 'Providence/Stoughton Line'
  direction_id = (ARGV[1] || 1).to_i
  tt = TransitTrips.new route, direction_id
  puts tt.trips
  puts tt.grid
end

__END__

#route = '1'
route = 'Providence/Stoughton Line'
query = <<QUERY
select stops.stop_name, stops.stop_code, st.* from stop_times_today('#{route}', 1) st join stops using(stop_id)
QUERY

@trips = Hash.new {|hash, key| hash[key] = []}
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
