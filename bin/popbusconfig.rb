require 'nextbus_feeds'

puts ARGV[0]
NextbusFeeds.get_route_config(ARGV[0])

