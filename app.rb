require 'sinatra'
require 'json'
require 'transit_routes'
require 'transit_trips'

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


get 'trips' do


end
