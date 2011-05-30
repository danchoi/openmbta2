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

  def self.unabbreviate(route)
    # TODO
    case route
    when /Massport/ 
      route[/\((\d+)\)$/, 1] 
    when /Silver Line SL\d/
      "SL#{route[/SL(\d)$/, 1]}"
    when "Green Line Shuttle"
      "Green Line"
    else
      route
    end
  end
end
