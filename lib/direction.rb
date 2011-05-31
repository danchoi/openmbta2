module Direction
  def self.id2name(direction_id, headsign=nil)
    dir = direction_id == 1 ? 'Inbound' : 'Outbound'
    #if headsign
    #  [dir, headsign ].join(': ')
    dir
  end

  def self.name2id(name)
    (name.downcase =~ /^inbound/) ? 1 : 0
  end
end
