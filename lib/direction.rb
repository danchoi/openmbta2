module Direction
  def self.id2name(direction_id)
    direction_id == 1 ? 'Inbound' : 'Outbound'
  end

  def self.name2id(name)
    name.downcase == 'inbound' ? 1 : 0
  end
end
