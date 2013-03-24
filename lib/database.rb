require 'sequel'
require 'logger'
#DB = Sequel.connect 'postgres:///mbta', :logger => Logger.new(STDOUT)
unless defined?(DB)
  DB = Sequel.connect 'postgres:///mbta'
end



