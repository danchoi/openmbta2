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
  puts view['modes'].inspect

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
        lat_span: (lats.max - lats.min),
        lng_span: (lngs.max - lngs.min)
      }
    end
    view.merge!({:trips => trips.to_json, :shapes => shapes.to_json, :region => region.to_json})
  end
  template = File.read 'index.html'
  Mustache.render template, view
end




