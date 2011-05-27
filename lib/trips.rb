require 'sequel'
DB = Sequel.connect 'postgres:///mbta'
# don't put semicolon at the end of sequel query
query = <<QUERY
select stops.stop_name, stops.stop_code, st.* from stop_times_today('1', 1) st join stops using(stop_id)
QUERY
DB[query].each do |row|
  puts row.inspect
end
