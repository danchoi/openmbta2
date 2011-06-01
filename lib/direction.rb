module Direction
  DIRECTION_MAPPING = {
    ['Blue Line',0] => 'Westbound',
    ['Blue Line',1] => 'Eastbound',
    ['Red Line',0] => 'Southbound',
    ['Red Line',1] => 'Northbound',
    ['Orange Line',0] => 'Southbound',
    ['Orange Line',1] => 'Northbound'
  }

  REVERSE_DIRECTION_MAPPING = DIRECTION_MAPPING.inject({}) {|memo, (k, v)|
    memo[ [k[0], v] ] = k[1]
    memo
  }

  def self.id2name(direction_id, route_types=nil, route=nil)
    if (route_types & [0,1]).size > 0 && (d = DIRECTION_MAPPING[[route, direction_id]])
      d
    else
      direction_id == 1 ? 'Inbound' : 'Outbound'
    end
  end

  def self.name2id(name, route=nil)
    name = name.split(':')[0]
    if name.downcase !~ /^\w+bound/
      raise OpenMBTA::InvalidDirection
    end
    REVERSE_DIRECTION_MAPPING[[route, name]] ||
      (name.downcase =~ /^inbound/ ? 1 : 0)
    
  end
end
