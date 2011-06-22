require 'nextbus_feeds'
require 'subway_feed'

%w(
NextbusFeeds.populate_route_list
NextbusFeeds.populate_route_configs
SubwayFeed.populate_keys
).each do |x|
  puts x
  eval(x)
end

# nothing to do for cr predictions
