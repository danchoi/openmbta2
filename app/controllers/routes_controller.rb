class RoutesController < ApplicationController
  def index
    route_types = case params[:transport_type].downcase
    when /bus/
      [3]
    when /rail/
      [2]
    when /boat/
      [4]
    when /subway/
      [0, 1]
    end
    res = TransitRoutes.routes(route_types)
    respond_to do |format|
      format.json {
        render :json => res.to_json
      }
      format.html {
        @result = res[:data]
        render :layout => 'mobile'
      }
    end
  end
end
