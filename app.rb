require 'sinatra'
require 'sequel'
require 'json'

DB = Sequel.connect "postgres:///mbta"

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
  sql = "select * from available_routes(now()) 
  as (route_type smallint, route varchar, direction_id smallint, trips_left bigint) 
  where route_type in ?"
  routes = DB[sql, route_types]
  res = {:data => []}
  routes.all.group_by {|x| x[:route]}.each do |route, directions|
    data = {:route_short_name => route, :headsigns => []}
    directions.each do |d|
      direction_name = d[:direction_id] == 0 ? 'Inbound' : 'Outbound'
      data[:headsigns] << [direction_name, d[:trips_left]] 
    end
    res[:data] << data
  end
  puts routes.all.to_json
  res.to_json
end
