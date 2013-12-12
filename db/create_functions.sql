-- use this to shorten coalescing with ifnull
CREATE FUNCTION coalesce2(varchar, varchar) RETURNS varchar AS $$ select
coalesce(nullif($1, ''), nullif($2, '')); $$ LANGUAGE SQL;



CREATE FUNCTION active_services(date) RETURNS setof varchar AS $$
select service_id from (
  select service_id from calendar 
  where service_days[(select to_char($1, 'ID'))::int] = true and start_date <= $1 and end_date >= $1
  UNION
  select service_id from calendar_dates 
  where exception_type = 'add' and date = $1
) services
EXCEPT 
  select service_id from calendar_dates 
  where exception_type = 'remove' and date = $1;
$$ language sql;


CREATE FUNCTION adjusted_time(x timestamp with time zone) RETURNS character(8) AS $$
DECLARE
  h integer;
  m integer;
BEGIN
  h := extract(hour from x);
  m := extract(minutes from x);
  IF h  < 4 THEN 
    h := h + 24;
  END IF;
  RETURN lpad(h::text, 2, '0') || ':' || lpad(m::text, 2, '0') || ':00';
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION adjusted_date(x timestamp with time zone) RETURNS date AS $$
BEGIN
  IF extract(hour from x) < 4 THEN 
    RETURN date( x - interval '24 hours' );    
  ELSE 
    RETURN date(x);
  END IF;
END;
$$ LANGUAGE plpgsql;



CREATE FUNCTION route_type_to_string(int) RETURNS VARCHAR as $$
select case 
when $1=0 then 'subway'
when $1=1 then 'subway'
when $1=2 then 'commuter rail'
when $1=3 then 'bus'
when $1=4 then 'boat'
else 'undefined' 
end;
$$ language sql;


-- used by dynamic html version


/*
drop view nearby_stops;
*/
