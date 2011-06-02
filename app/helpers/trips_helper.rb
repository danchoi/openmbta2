module TripsHelper

  def realtime_arrivals(stop_id)
    x = @result[:stops][stop_id.to_s]
    return unless x
    if x[:next_arrivals][-1][0] =~ /realtime/
      x[:next_arrivals][0..-2].map {|x| x[0]}.join(", ")
    end
  end
end
