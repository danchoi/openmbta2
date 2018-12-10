select r.route_id ,
(case when r.route_type = 3 then coalesce(r.route_short_name, r.route_id) else coalesce(nullif(r.route_long_name, ''), nullif(r.route_short_name, '')) end)  
route_coalesced_name
from routes r
-- where (case when r.route_type = 3 then coalesce(r.route_short_name, r.route_id) else coalesce(nullif(r.route_long_name, ''), nullif(r.route_short_name, '')) end)  = 'Middleborough/Lakeville Line' ;

