require 'database'
require 'nokogiri'
require 'open-uri'
require 'csv'

module RealtimeSubway

  class << self
    def populate_keys
      fields = {"Line"=>"Blue", "PlatformKey"=>"BORHW", "PlatformName"=>"ORIENT HEIGHTS WB", "StationName"=>"ORIENT HEIGHTS", "PlatformOrder"=>"4", "StartOfLine"=>"FALSE", "EndOfLine"=>"FALSE", "Branch"=>"Trunk", "Direction"=>"WB", "stop_id"=>"place-orhte", "stop_code"=>nil, "stop_name"=>"Orient Heights Station", "stop_desc"=>nil, "stop_lat"=>"42.386867", "stop_lon"=>"-71.004736"}.keys

      url = 'http://developer.mbta.com/RT_Archive/RealTimeHeavyRailKeys.csv'
      handle = open(url)
      DB[:rt_subway_keys].delete
      CSV.new(handle, headers: :first_row).each do |row|
        data = row.to_hash
        data = data.inject({}) do |memo, (k, v)|
          memo[ camel2underscore(k) ] = v
          memo
        end
        DB[:rt_subway_keys].insert data
      end
    end


    def camel2underscore(s)
      s.gsub(/(\w)([A-Z])/) {|match|
        "#{$1}_#{$2}"
      }.downcase.to_sym
    end
  end
end

if __FILE__ == $0
  RealtimeSubway.populate_keys
end
