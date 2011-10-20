require 'yaml'
require 'database'
require 'json'

shape_id = '010017'

res = DB["select ST_AsGeoJSON(geog) as json from polylines where shape_id = ?", shape_id].first.to_hash[:json]

linestring = JSON.parse(res)["coordinates"].to_json

x = {:shape_id => shape_id, :linestring => linestring}

puts x.inspect
