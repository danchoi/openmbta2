require 'sequel'
DB = Sequel.connect 'postgres:///mbta'
# don't put semicolon at the end of sequel query
query = <<QUERY
select stops.stop_name, stops.stop_code, st.* from stop_times_today('1', 1) st join stops using(stop_id)
QUERY

trips = Hash.new {|hash, key| hash[key] = []}
stops = Hash.new {|hash, key| hash[key] = []}
DB[query].each do |row|
  #puts row.inspect
  trip_id = row[:trip_id]
  stop_name = row[:stop_name]
  stopping = [ row[:arrival_time], row[:trip_id] ]
  trips[trip_id] << stopping
  stops[stop_name] << stopping
end
puts '-' * 80

trips.each do |k, v|
  puts k
  puts v.inspect
end
stops.each do |k, v|
  puts k
  puts v.inspect
end

