require 'database'
require 'nokogiri'
require 'csv'
require 'timeout'

module SubwayFeed

  class << self

    def open(url)
      `curl -Ls '#{url}'`
    end

# broken 
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
          'NB' => 'Northbound', 'SB' => 'Southbound',
          'EB' => 'Eastbound', 'WB' => 'Westbound'
        }
        dir_id = direction_mapping[data[:direction]]
        data[:direction] = dir_id
        DB[:rt_subway_keys].insert data
      end
    end

    def get_predictions(line)
      puts "Getting predictions for #{line} at #{Time.now}"
      Timeout::timeout(5) do 
        url = "http://developer.mbta.com/Data/#{line}.txt"
        puts url
        handle = open(url)
        line = line.capitalize
        DB.run("delete from rt_subway_predictions  where line = '#{line}'")
        headers = %w( line trip_id platform_key information_type arrival_time wait_time revenue route ).map {|x| x.to_sym}
        i = 0
        CSV.new(handle, headers: headers).each do |row|
          data = row.to_hash
          if data[:revenue].strip != 'Revenue'
            puts data.inspect
            next
          end
          data = data.inject({}) {|memo, (k, v)|
            memo[k] = v.is_a?(String) ? v.strip : v
            memo
          }
          data.delete(:wait_time)
          data.delete(:revenue)
          DB[:rt_subway_predictions].insert data
          i += 1
        end
        puts "-- #{i} records created"
      end
    rescue Timeout::Error
      puts "Timeout error"
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
  SubwayFeed.get_all_predictions 
end
