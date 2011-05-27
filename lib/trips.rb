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
  stopping = [ row[:arrival_time], row[:stop_name], row[:stop_sequence] ]
  trips[row[:trip_id]] << stopping
end

puts '-' * 80

#puts trips.to_yaml

trips.each do |k, v|
  puts k
  puts v.sort_by {|x| x[-1]}.inspect
end
