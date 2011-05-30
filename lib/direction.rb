module Direction
  def self.id2name(direction_id)
    direction_id == 0 ? 'Inbound' : 'Outbound'
  end

  def self.name2id(name)
    name.downcase == 'inbound' ? 0 : 1
  end
end
