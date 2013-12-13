require 'dalli'
options = { }
dc = Dalli::Client.new()
puts dc.get('abc').inspect
puts dc.get('abc1').inspect
dc.set('abc', 123, 5)
value = dc.get('abc')
puts value.inspect

