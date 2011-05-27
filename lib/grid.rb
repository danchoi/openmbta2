def grid
  trips = @trips
  trip_ids = @trips.map(&:id)
  @grid = [] 
  @first_stops = []
  @trips.each_with_index do |trip, col|
    next_grid_row = 0
    trip.stoppings.each_with_index do |stopping, i|
      stop = stopping.stop
      time = stopping.arrival_time
      pos = stopping.position
      if i == 0 && !@first_stops.include?(stop)
        @first_stops << stop
        #puts "FIRST STOPS"
        #puts @first_stops.inspect
      end
      stop_row = @grid.detect {|x| x.is_a?(Hash) && x[:stop] && x[:stop][:stop_id] == stop.id}
      if stop_row
        stop_row[:times][col] = time
        next_grid_row = @grid.index(stop_row) + 1
      else
        values = Array.new(@trips.size)
        values[col] = time
        stop_id = stop.id
        name = stop.name
        lat = stop.lat
        lng = stop.lng
        hash = {:stop_id => stop_id, :name => name, :lat => lat.to_f, :lng => lng.to_f}
        stop_row = {:stop => hash, :times => values}
        @grid.insert(next_grid_row, stop_row)
        next_grid_row += 1
      end
    end
  end
  puts @grid.inspect
  @grid
end

