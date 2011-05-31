require 'database'
module BusRoutes
  # Shortens the route name for Massport Ferry Terminal Shuttle and Silver Line SL5
  # Ideally, this should have been done on the iOS client side.
  def self.abbreviate(route)
    if route.length > 4
      case route
      when /Massport/ 
        'Massport ' + route[/\((\d+)\)$/, 1] 
      when /Silver Line SL\d/
        "SL#{route[/SL(\d)$/, 1]}"
      when "Green Line Shuttle"
        "Green Line"
      else
        route
      end
    else
      route
    end
  end

  def self.find_route(route)
    case route 
    when /Massport/ 
      DB["select route_long_name from routes where route_long_name like ?", "%#{route[/\d+/,0]}%"].first[:route_long_name]
    when /SL\d/
      DB["select route_long_name from routes where route_short_name = ?", route].first[:route_long_name]
    when "Green Line"
      "Green Line Shuttle"
    else
      route
    end
  end
end

if __FILE__ == $0
  puts BusRoutes.find_route ARGV.first
end
