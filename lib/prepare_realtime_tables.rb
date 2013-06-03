require 'sequel'

db = ARGV.first || 'mbta2'
DB = Sequel.connect "postgres:///#{db}"

require 'nextbus_feeds'
require 'subway_feed'


NextbusFeeds.populate_route_list
NextbusFeeds.populate_route_configs
SubwayFeed.populate_keys

# nothing to do for cr predictions
