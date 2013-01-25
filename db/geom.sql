
-- add Geom column to stops
select AddGeometryColumn('stops', 'geom', 4326, 'POINT', 2);
update stops set geom = ST_GeomFromText('POINT(' || stop_lon || ' ' || stop_lat || ')', 4326);
create index idx_stops_geom on stops using gist(geom);


-- This makes linestrings
-- select AddGeometryColumn('shapes', 'geom', 2163, 'POINT', 2);
alter table shapes add column geog geography(POINT,4326);
update shapes set geog = ST_GeogFromText('SRID=4326;POINT(' || shape_pt_lon || ' ' || shape_pt_lat || ')');

-- select AddGeometryColumn('polylines', 'geom', 2163, 'LINESTRING', 2);
create table polylines ( 
  shape_id varchar(255) primary key,
  geog geography(LINESTRING,4326)
);

create index idx_polylines_geog on polylines using gist(geog);

-- see http://www.mentby.com/sandro-santilli/makeline-for-geography-coordinates.html 
insert into polylines (shape_id, geog) select shapes.shape_id, ST_Makeline(shapes.geog::geometry)::geography as polyline 
  from (select shape_id, shapes.geog from shapes order by shape_id, shape_pt_sequence) as shapes
  group by shapes.shape_id;

-- example queries

-- select shape_id, ST_NumPoints(geom)  from polylines;

-- select shape_id, ST_Length(geom) from polylines;
-- select shape_id, ST_Summary(geom) from polylines;
-- select ST_AsGeoJSON(ST_Transform(geom, 4263)) from polylines limit 1;

