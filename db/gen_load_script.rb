# generates the "load data local infile" script load.sql from the data/*.txt
# NOW FOR POSTGRESQL, not MySQL
require 'csv'
Dir["data/*.txt"].
  select {|f| 
    f !~ /calendar/ &&
    f !~ /feed_info/
  }.each do |file|

  $stderr.print "Processing file: #{file} -> "
  table = File.basename(file, ".txt")
  head = `head -1 #{file}`.split("\r\n")[0]
  begin
    fields = CSV.parse_line(head)
  rescue
    raise $!
  end
  #$stderr.puts fields.inspect
  outfile = (file =~ /stop_times/) ? file.sub(".txt", ".fixed") : file
  path = File.expand_path "../#{outfile}", File.dirname(__FILE__) 
  $stderr.print "#{path}\n"
  sql = <<SQL
truncate #{table};
copy #{table} from  '#{path}'
DELIMITER AS ',' CSV HEADER;
SQL
  puts sql
  $stderr.puts sql
end

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


