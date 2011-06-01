require 'sinatra'
require 'json'
require 'transit_routes'
require 'transit_trips'
require 'direction'
require 'merge_realtime'
require 'rexml/document'

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
  direction = params['headsign']
  direction_id = Direction.name2id(direction, route) # now inbound or outbound
  puts params.inspect
  begin
    if params[:transport_type] == 'Bus'
      route = BusRoutes.find_route(route)
    end
    x = TransitTrips.new(route, direction_id)
    result = x.result
    resp = if params[:transport_type] == 'Bus' && RealtimeBus.available?(route, direction_id) 
             realtime = RealtimeBus.new(route, direction_id) 
             MergeRealtime.merge(result, realtime) 
           elsif params[:transport_type] == 'Subway' && RealtimeSubway.available?(route, direction) 
             realtime = RealtimeSubway.new(route, direction)  # use direction label
             MergeRealtime.merge(result, realtime, :subway) 
           else 
             result 
           end
    resp.to_json
  rescue TransitTrips::NoRouteData
    resp = {message: {title: 'Alert', body: 'No trips found'}}
    resp.to_json
  end
end

helpers do
  def link_to text, url
    "<a href='#{url}'>#{text}</a>"
  end

  def image_tag url, opts={}
    "<img src='#{url}' style='#{opts[:style]}'/>"
  end
end

get '/' do
  File.read(File.join('public', 'index.html'))
end

get '/mobile.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss :mobile
end

get '/help/:target_controller/:transport_type' do
  @transport_type = params[:transport_type] || "bus"
  if ['subway', 'commuter rail'].include? @transport_type.downcase
    @transport_type = @transport_type + ' train'
  end
  haml :help
end

get '/tweets' do
  cmd  = "curl -s http://search.twitter.com/search.atom?q=%23mbta"
  xml_string = `#{cmd}`
  doc = REXML::Document.new(xml_string)
  @entries = []
  doc.elements.each("//entry") do |entry|
    image = nil
    # This long winded way is required because of a weird server Ruby issue
    entry.each_element_with_attribute("rel", "image") {|link| image = link.attributes["href"]}
    @entries << { :published => DateTime.parse(entry.elements["published"].text),
      :image => image,
      :name => entry.elements["author/name"].text,
      :uri => entry.elements["author/uri"].text,
      :content => entry.elements["content"].text
    }
  end
  haml :tweets
end

get '/alerts' do

end

get '/alerts/:guid' do

end


