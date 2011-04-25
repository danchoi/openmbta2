#!/usr/bin/env ruby
require 'date'
# pass in a YYYYMMDD date string and this program 
# will return a list of service_id in service for that day.

# TODO make this return the list of service ideas as a bare list?

date = %Q("#{ARGV.first || Date.today.strftime("%Y%m%d")}")
# find weekday
wday = Date.parse(date).wday
type = case wday
       when 6
         "Saturday"
       when 0
         "Sunday"
       else
         "Weekday"
       end
  
sql = <<SQL
select c.service_id, start_date, end_date, cd.exception_type, cd.date exception_date
from calendar c
left outer join
  calendar_dates cd
    on
      exception_type = 1 
      and cd.service_id = c.service_id
        and cd.date = #{date}

where 
  (start_date <= #{date}
    and end_date >= #{date}
    and c.service_id like "%#{type}%" /* this is particular to MBTA's service_id's */
    and c.service_id not in
      (select service_id 
        from calendar_dates
        where exception_type = 2
          and date = #{date}))
  or
  (c.service_id in 
    (select service_id
      from calendar_dates
      where exception_type = 1
        and date = #{date}))
SQL

puts sql

