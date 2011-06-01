require 'database'
require 'nokogiri'
require 'open-uri'
require 'csv'

module SubwayFeed

  class << self
    def populate_keys
      url = 'http://developer.mbta.com/RT_Archive/RealTimeHeavyRailKeys.csv'
      handle = open(url)
      DB[:rt_subway_keys].delete
      CSV.new(handle, headers: :first_row).each do |row|
        data = row.to_hash
        data = data.inject({}) do |memo, (k, v)|
          memo[ camel2underscore(k) ] = v
          memo
        end
        direction_mapping = {
          'NB' => 'Northbound', 'SB' => 'Soutbound',
          'EB' => 'Eastbound', 'WB' => 'Westbound'
        }
        dir_id = direction_mapping[data[:direction]]
        data[:direction] = dir_id
        DB[:rt_subway_keys].insert data
      end
    end

    def get_predictions(line)
      handle = open("http://developer.mbta.com/Data/#{line}.txt")
      DB.run("delete from rt_subway_predictions  where line = '#{line}'")
      headers = %w( line trip_id platform_key information_type arrival_time wait_time revenue route ).map {|x| x.to_sym}
      i = 0
      CSV.new(handle, headers: headers).each do |row|
        data = row.to_hash
        data = data.inject({}) {|memo, (k, v)|
          memo[k] = v.is_a?(String) ? v.strip : v
          memo
        }
        data.delete(:wait_time)
        data.delete(:revenue)
        DB[:rt_subway_predictions].insert data
        i += 1
      end
      puts "Got predictions for #{line} at #{Time.now} -- #{i} records created"
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
  #SubwayFeed.populate_keys
  loop do
    SubwayFeed.get_all_predictions 
    sleep 15
  end
end
