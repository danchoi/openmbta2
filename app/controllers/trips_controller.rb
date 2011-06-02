class TripsController < ApplicationController

  def index
    # irrelevant for now params[:headsign]
    route = params['route_short_name']
    direction = params['headsign'].split(':')[0]
    begin
      direction_id = Direction.name2id(direction, route) # now inbound or outbound
      if params[:transport_type] == 'Bus'
        route = BusRoutes.find_route(route)
      end
      x = TransitTrips.new(route, direction_id)
      result = x.result
      resp = if params[:transport_type] =~ /bus/i && RealtimeBus.available?(route, direction_id) 
               realtime = RealtimeBus.new(route, direction_id) 
               MergeRealtime.merge(result, realtime) 
             elsif params[:transport_type] =~ /subway/i && RealtimeSubway.available?(route, direction) 
               realtime = RealtimeSubway.new(route, direction)  # use direction label
               MergeRealtime.merge(result, realtime, :subway) 
             else 
               result 
             end
    rescue TransitTrips::NoRouteData, OpenMBTA::InvalidDirection
      resp = {message: {title: 'Invalid Bookmark', body: 'You may need to delete all your old bookmarks and create new ones. The dataset has changed. Sorry for the inconvenience.'}}
      render :json => resp.to_json
    end
    respond_to do |format|
      format.json { render :json => resp.to_json }
      format.html {
        @result = resp
        @grid = @result[:grid]
        if @result[:message]
          logger.debug @result[:message]
          render(:text => @result[:message][:body]) 
        else
          @num_columns = 6
          @num_pages = (@grid[0][:times].length.to_f / @num_columns).ceil
          @current_column = nil
          i = 0
          while @current_column.nil?
            @current_column = @grid[i][:times].index {|time, flag| flag == 1}
            i += 1
          end
          @current_page = (@current_column.to_f / @num_columns).floor
          @stops = @result[:stops].map {|k,v| v[:stop_id] = k; v}
          render :layout => 'mobile'
        end
      }
    end
  end
end
