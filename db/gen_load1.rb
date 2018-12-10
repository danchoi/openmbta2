require 'csv'
DB=ARGV[0] || abort("DB name as 1st arg")
Dir["data/*.txt"].
  select {|f| 
    f !~ /calendar|feed_info|facilities|levels|pathways|transfers|checkpoints/
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
psql #{DB} -c 'truncate #{table};'
cat #{path} | psql #{DB} -c "copy #{table} from STDIN WITH DELIMITER ','  CSV HEADER;"
SQL
  puts sql
end


