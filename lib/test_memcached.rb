require 'memcached'
$cache = Memcached.new("localhost:11211")

value = 'hello'
puts $cache.set('test', value, 1)
sleep 2
puts $cache.get('test') #=> "hello"
