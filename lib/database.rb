require 'sequel'
require 'logger'
require 'dalli'

#DB = Sequel.connect 'postgres:///mbta', :logger => Logger.new(STDOUT)
unless defined?(DB)
  DB = Sequel.connect 'postgres:///mbta'
end

MEMCACHED = Dalli::Client.new


