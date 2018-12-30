require 'csv'
DB=ARGV[0] || abort("DB name as 1st arg")
Dir["data/*.txt"].
  select {|f| 
    ["data/agency.txt", "data/trips.txt", "data/stop_times.txt" ].include?(f)
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
echo 'loading table #{table}'
psql #{DB} -c 'truncate #{table};'
cat #{path} | psql #{DB} -c "copy #{table} from STDIN WITH DELIMITER ','  CSV HEADER;"
SQL
  puts sql
end

puts <<END
echo 'loading table stops'
psql #{DB} -c "truncate stops;"
cat data/stops.txt | psql #{DB} -c "copy stops (stop_id,stop_name,stop_desc,stop_lat,stop_lon,level_id,location_type,parent_station,wheelchair_boarding,stop_code,platform_code,platform_name,zone_id,stop_url,stop_address) from STDIN WITH DELIMITER ','  CSV HEADER;"
echo 'loading table routes'
psql #{DB} -c "truncate routes;"
cat data/routes.txt | psql #{DB} -c "copy routes ( route_id,agency_id,route_short_name,route_long_name,route_desc,route_fare_class,route_type,route_url,route_color,route_text_color,route_sort_order,line_id,listed_route) from STDIN WITH DELIMITER ','  CSV HEADER;"
END
