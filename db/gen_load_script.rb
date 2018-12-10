require 'csv'
# improve the calendar schema
file = 'data/calendar.txt'
CSV.foreach(file, headers: true) do |row|
  service_days = "{" + (1..7).map {|i| row[i] == "1"}.join(",") + "}"
  sql = "insert into calendar (service_id, service_days, start_date, end_date) " +
  "values ('%s', '%s', '%s', '%s');" % [row[0], service_days, row[-2], row[-1]]
  puts sql
end

CSV.foreach('data/calendar_dates.txt', headers: true) do |row|
  exception = row[2].to_i == 1 ? 'add' : 'remove'
  sql = "insert into calendar_dates (service_id, date, exception_type) " +
  "values ('%s', '%s', '%s');" % [row[0], row[1], exception]
  puts sql
end

__END__


into table #{table}
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\\r\\n'
ignore 1 lines
(#{fields.join(', ')});


