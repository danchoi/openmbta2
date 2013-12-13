require 'dalli'
options = { :namespace => "openmbta", :compress => true }
dc = Dalli::Client.new('localhost:11211', options)
puts dc.get('abc').inspect
puts dc.get('abc1').inspect
dc.set('abc', 123, 2)
value = dc.get('abc')
puts value

