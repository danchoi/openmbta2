# generates the "load data local infile" script load.sql from the data/*.txt
# NOW FOR POSTGRESQL, not MySQL
require 'csv'
Dir["data/*.txt"].each do |file|
  table = File.basename(file, ".txt")
  #$stderr.puts "processing #{file}: #{table}"
  head = `head -1 #{file}`.split("\r\n")[0]
  fields = CSV.parse_line(head)
  #$stderr.puts fields.inspect
  path = File.expand_path "../#{file}", File.dirname(__FILE__)
  sql = <<SQL
delete from #{table};
load data local infile  '#{path}'
  into table #{table}
  fields terminated by ','
  optionally enclosed by '"'
  lines terminated by '\r\n'
  ignore 1 lines;

SQL
  puts sql
end

__END__


into table #{table}
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\\r\\n'
ignore 1 lines
(#{fields.join(', ')});


