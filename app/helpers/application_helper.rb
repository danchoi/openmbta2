module ApplicationHelper

  def format_time(datetime)
    datetime.in_time_zone.strftime('%x %I:%M %p')
  end
end
