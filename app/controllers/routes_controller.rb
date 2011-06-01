class RoutesController < ApplicationController
  def show
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
    render :json => res.to_json
  end
end
