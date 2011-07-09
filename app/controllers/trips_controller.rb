class TripsController < ApplicationController

  def index
    # irrelevant for now params[:headsign]
    route = params['route_short_name']
    direction = params['headsign'].split(':')[0]
    begin
      if params[:transport_type] =~ /bus/i
        route = BusRoutes.find_route(route)
      end
      direction_id = Direction.name2id(direction, route) # now inbound or outbound
      x = TransitTrips.new(route, direction_id)
      result = x.result
      resp = if params[:transport_type] =~ /bus/i && RealtimeBus.available?(route, direction_id) 
               realtime = RealtimeBus.new(route, direction_id) 
               MergeRealtime.merge(result, realtime) 
             elsif params[:transport_type] =~ /subway/i && RealtimeSubway.available?(route, direction) 
               realtime = RealtimeSubway.new(route, direction)  # use direction label
               MergeRealtime.merge(result, realtime, :subway) 
             elsif params[:transport_type] =~ /rail/i
               MergeRealtimeCommuterRail.merge(result)
             else 
               result 
             end
      resp.merge!(:ads => "iAds")
      # This may cause mismatches for bus routes like "Green Line", but OK for now
      alert = DB["select * from t_alerts where ? ~ split_part(title, ' ', 1) and pubdate > now() - interval '1 hour'  order by pubdate desc", route].first
      if alert
        resp[:message] = {title: 'T-Alert', body: alert[:description]}
      end
    rescue TransitTrips::NoRouteData, OpenMBTA::InvalidDirection
      resp = {message: {title: 'Invalid Bookmark', body: 'Because of recent database changes, please delete all your old bookmarks. Tap the blue Bookmarked button to unbookmark this and other routes that show this message.'}}
      respond_to do |format|
        format.json {
          render :json => resp.to_json
        }
        format.html {
          render :text => resp[:message]
        }
      end
      return
    end
    respond_to do |format|
      format.json { render :json => resp.to_json }
      format.html {
        @result = resp
        @grid = @result[:grid]
        @num_columns = 6
        @num_pages = (@grid[0][:times].length.to_f / @num_columns).ceil
        @current_column = nil
        i = 0
        while @current_column.nil?
          if @grid[i].nil?
            break
          end
          @current_column = @grid[i][:times].index {|time, flag| flag == 1}
          i += 1
        end
        @current_page = (@current_column.to_f / @num_columns).floor
        @stops = @result[:stops].map {|k,v| v[:stop_id] = k; v}
        render :layout => 'mobile'
      }
    end
  end
end
