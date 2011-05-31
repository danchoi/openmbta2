require 'sinatra'
require 'json'
require 'transit_routes'
require 'transit_trips'
require 'direction'

# TODO start logging analytics

get '/routes/:transport_type' do
  route_types = case params[:transport_type].downcase
  when /bus/
    [3]
  when /rail/
    [2]
  when /boat/
    [4]
  when /subway/
    [0, 1]
  end
  res = TransitRoutes.routes(route_types)
  res.to_json
end

get '/trips' do
  # irrelevant for now params[:headsign]
  route = params['route_short_name']
  direction_id = Direction.name2id params['headsign'] # now inbound or outbound
  puts params.inspect
  begin
    if params[:transport_type] == 'Bus'
      route = BusRoutes.find_route(route)
    end
    x = TransitTrips.new(route, direction_id)
    x.result.to_json
  rescue TransitTrips::NoRouteData
    puts "eception'{w;"
  end

end
