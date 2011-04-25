-- This makes linestrings
select AddGeometryColumn('shapes', 'geom', 2163, 'POINT', 2);

update shapes set geom = ST_Transform(ST_GeomFromText('POINT(' || shape_pt_lon || ' ' || shape_pt_lat || ')', 4326), 2163 );

create table polylines ( shape_id varchar(255) primary key );

select AddGeometryColumn('polylines', 'geom', 2163, 'LINESTRING', 2);

create index idx_polylines_geom on polylines using gist(geom);

insert into polylines (shape_id, geom) select shapes.shape_id, ST_Transform( ST_Makeline(shapes.geom), 2163 ) as polyline 
  from (select shape_id, shapes.geom from shapes order by shape_id, shape_pt_sequence) as shapes
  group by shapes.shape_id;

-- example queries

-- select shape_id, ST_NumPoints(geom)  from polylines;

-- select shape_id, ST_Length(geom) from polylines;
-- select shape_id, ST_Summary(geom) from polylines;
-- select ST_AsGeoJSON(ST_Transform(geom, 4263)) from polylines limit 1;

