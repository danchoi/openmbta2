require 'sinatra'
require 'mustache'
require 'sequel'
require 'logger'
require 'yaml'
require 'json'

DB = Sequel.connect 'postgres:///mbta'


get '/' do
  view = {}
  view['modes'] = DB["select * from view_available_routes"].to_a.group_by {|x|
    x[:route_type]
  }.map {|(group, values)|
    {
      'group' => group, 
      'routes' => values.map {|x| 
        x.delete(:route_type)
        if params[:route] == x[:route]
          x[:selected] = true
        end
        x 
      }
    }
  }

  if (route = params[:route])
    direction = params[:direction] || 0
    trips = DB["select * from route_trips_today(?, ?)", route, direction.to_i].to_a

    lines = []
    shapes = trips.select {|t| t[:shape_id]}.
      map {|t| t[:shape_id]}.
      inject({}) do |m, s|
        r = DB["select ST_AsGeoJSON(geog) as json from polylines where shape_id = ?", s].first
        next m if r.nil?
        r = r[:json]
        line = JSON.parse(r)["coordinates"]
        if m[s].nil?
          m[s] = line
          lines << line
        end
        m
      end
    lats = lines.map {|line| line.map {|c| c[1]}}.flatten
    lngs = lines.map {|line| line.map {|c| c[0]}}.flatten
    region = if !lats.empty? && !lngs.empty?
      { 
        center: [((lngs.max + lngs.min) / 2), ((lats.max + lats.min) / 2)],
        sw: [lats.min, lngs.min],
        ne: [lats.max, lngs.max]
      }
    end

    # find all stops

    stoppings = DB["select stop_id, stop_code, stop_name, stop_lat, stop_lon, trip_id, arrival_time, stop_sequence 
    from route_stops_today(?, ?) as 
    (stop_id varchar, stop_code varchar, stop_name varchar, stop_lat double precision, stop_lon double precision, trip_id varchar, arrival_time varchar, stop_sequence integer)", route, direction].to_a

    stops = stoppings.reduce({}) do |m, s|
      key = s[:stop_id]
      m[key] ||= s.delete_if {|k, v| [:arrival_time, :stop_sequence, :stop_code, :trip_id].include?(k)}
      m
    end.values

    view.merge!({:trips => trips.to_json, :shapes => shapes.to_json, :region => region.to_json, 
      :stops_json => stops.to_json, :stops => stops})
  end
  template = File.read 'index.html'
  Mustache.render template, view
end




