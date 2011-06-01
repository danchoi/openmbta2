class TripsController < ApplicationController

  def show
    # irrelevant for now params[:headsign]
    route = params['route_short_name']
    direction = params['headsign']
    direction_id = Direction.name2id(direction, route) # now inbound or outbound
    begin
      if params[:transport_type] == 'Bus'
        route = BusRoutes.find_route(route)
      end
      x = TransitTrips.new(route, direction_id)
      result = x.result
      resp = if params[:transport_type] == 'Bus' && RealtimeBus.available?(route, direction_id) 
               realtime = RealtimeBus.new(route, direction_id) 
               MergeRealtime.merge(result, realtime) 
             elsif params[:transport_type] == 'Subway' && RealtimeSubway.available?(route, direction) 
               realtime = RealtimeSubway.new(route, direction)  # use direction label
               MergeRealtime.merge(result, realtime, :subway) 
             else 
               result 
             end
      render :json => resp.to_json
    rescue TransitTrips::NoRouteData
      resp = {message: {title: 'Alert', body: 'No trips found, You may need to update your bookmark, as the dataset has changed.'}}
      render :json => resp.to_json
    end
  end
end
