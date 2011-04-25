select service_id, start_date, end_date 
from calendar
where 
  (start_date >= ?
    and end_date <= ?
    and service_id not in
      (select service_id 
        from calendar_dates
        where exception_type = 2
          and date = ?))
  or
  (service_id in 
    (select service_id
      from calendar_dates
      where exception_type = 1
        and date = ?))
;
