module TimeFormatter
  def format_and_flag_time(time) # time is HH:MM:SS
    return unless time
    # strip off seconds
    hour, min = *time.split(':')[0,2]
    time_string = time[/^(\d{2}:\d{2})/, 1]
    now_hour = Time.now.hour

    if now_hour < 4 # 24 hour clock, 1 am
      now_hour += + 24
    end
    time_now = "%.2d:%.2d" % [now_hour, Time.now.min]
    if time_string < time_now
      [format_time(time), -1]
    else
      [format_time(time), 1]
    end
  end

  def format_time(time)
    # "%H:%M:%S" -> 12 hour clock with am or pm
    hour, min, secs = *time.split(":")
    if secs.to_i > 29
      min = "%.2d" % (min.to_i + 1)
    end
    hour = hour.to_i
    suffix = 'a'
    if hour > 24
      hour = hour - 24
    elsif hour == 12
      suffix = 'p'
    elsif hour == 24
      hour = 12
      suffix = 'a'
    elsif hour > 12
      hour = hour - 12
      suffix = 'p'
    elsif hour == 0
      suffix = 'a'
      hour = 12 # midnight
    end
    "#{hour}:#{min}#{suffix}"
  end


end

