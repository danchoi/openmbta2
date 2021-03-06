require 'sequel'
require 'logger'
require 'dalli'

#DB = Sequel.connect 'postgres:///mbta', :logger => Logger.new(STDOUT)
unless defined?(DB)
  db = (ENV['DB'] || File.read('DATABASE')).strip
  STDERR.puts "Using db: #{db}"
  DB = Sequel.connect "postgres:///#{db}"
end

MEMCACHED = Dalli::Client.new


