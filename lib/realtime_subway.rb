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

    def get_predictions(line)
      handle = open("http://developer.mbta.com/Data/#{line}.txt")
      DB.run("delete from rt_subway_predictions  where line = '#{line}'")
      headers = %w( line trip_id platform_key information_type arrival_time wait_time revenue route ).map {|x| x.to_sym}
      CSV.new(handle, headers: headers).each do |row|
        data = row.to_hash
        data = data.inject({}) {|memo, (k, v)|
          memo[k] = v.is_a?(String) ? v.strip : v
          memo
        }
        data.delete(:wait_time)
        data.delete(:revenue)
        DB[:rt_subway_predictions].insert data
      end
    end

    def get_all_predictions
      %w( Red orange blue ).each do |line|
        get_predictions line
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
  #RealtimeSubway.populate_keys
  RealtimeSubway.get_all_predictions 
end
