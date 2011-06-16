require'database'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'timeout'
require 'pp'

# commuter rail feeds
module CrFeeds

  FEEDS = { '1' => 'Greenbush Line',
    '2' => 'Kingston/Plymouth Line',
    '3' => 'Middleborough/Lakeville Line',
    '4' => 'Fairmount Line',
    '5' => 'Providence/Stoughton Line',
    '6' => 'Franklin Line',
    '7' => 'Needham Line',
    '8' => 'Framingham/Worcester Line',
    '9' => 'Fitchburg Line',
    '10' => 'Lowell Line',
    '11' => 'Haverhill Line',
    '12' => 'Newburyport/Rockport Line' }

  class << self

    def get_predictions(feednum)
      route = FEEDS[feednum.to_s]
      url = "http://developer.mbta.com/lib/RTCR/RailLine_#{feednum}.csv"
      handle = open(url)
      # headers = %w( TimeStamp Trip Destination Stop Scheduled Flag Vehicle Latitude Longitude Heading Speed Lateness )
      CSV.new(handle, headers: true).each do |row|
        data = row.to_hash.inject({}) do |memo, (key, value)|
          newkey = key.to_s.downcase.to_sym
          memo[newkey] = if %w(TimeStamp Scheduled).include?(key)
                           Time.at(value.to_i)
                         else
                           value
                         end
          memo
        end
        data[:route] = route
        DB[:rt_cr_predictions].insert data
      end
    end
  end
end

if __FILE__ == $0
  DB.run("delete from rt_cr_predictions")
  1.upto(12) do |i|
    CrFeeds.get_predictions i
  end
end



