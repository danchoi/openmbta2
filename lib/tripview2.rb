# generates trip data for html5 view

require 'database'
require 'json'
require 'yaml'

route, direction = *ARGV

trips = DB["select * from route_trips_today(?, ?)", route, direction].to_a

lines = []
shapes = trips.map {|t| t[:shape_id]}.inject({}) do |m, s|
  r = DB["select ST_AsGeoJSON(geog) as json from polylines where shape_id = ?", s].first.to_hash[:json]
  line = JSON.parse(r)["coordinates"]
  pts = line
  x = pts
  if m[s].nil?
    m[s] = x
    lines << line
  end
  m
end


lats = lines.map {|line| line.map {|c| c[1]}}.flatten
lngs = lines.map {|line| line.map {|c| c[0]}}.flatten
lat_span = lats.max - lats.min
lng_span = lngs.max - lngs.min
lat_center = (lats.max + lats.min) / 2
lng_center = (lngs.max + lngs.min) / 2

region = {
  center: [lng_center, lat_center],
  lat_span: lat_span,
  lng_span: lng_span
}

r = {'trips' => trips.to_json, 'shapes' => shapes.to_json, 'region' => region.to_json}
puts r.to_yaml
puts '---'

