require 'database'
require 'nokogiri'
require 'open-uri'

module Nextbus

  class << self
    def populate_route_list
      url = 'http://webservices.nextbus.com/service/publicXMLFeed?command=routeList&a=mbta'
      Nokogiri::XML.parse(open(url)).search("route").each do |r|
        params = {
          tag: r[:tag],
          title: r[:title]
        }
        DB[:nextbus_routes].insert params
      end
    end

    def populate_route_configs
      DB[:nextbus_routes].all.each do |route|
        get_route_config route[:tag]
      end
    end

    def get_route_config(route_tag)
      url = "http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=mbta&r=#{route_tag}"
      xml = Nokogiri::XML.parse(open(url))
      DB["delete from nextbus_route_configs where routetag = ?", route_tag]
      xml.search("route").each do |route|
        route[:tag]
        route.xpath("stop").each do |stop|
          params = {
            routetag: route_tag,
            stoptag: stop[:tag],
            stoptitle: stop[:title]
          }
          puts params.inspect
          DB[:nextbus_route_configs].insert params
        end
      end
    end

    def get_predictions(route_tag)
      url = 'http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a=mbta'
      params = get_stop_tags(route_tag).map {|stoptag| "stops=#{route_tag}|null|#{stoptag}"}.join('&')
      url += "&" + params
      xml = `curl -s '#{url}'` # open-uri doesn't work on this long url
      DB["delete from nextbus_predictions where routetag = ? ", route_tag]
      Nokogiri::XML.parse(xml).xpath('//predictions').each do |s|
        stop_tag = s[:stopTag] 
        s.xpath('./direction/prediction').each do |p|
          params = {
            routetag: route_tag,
            stoptag: stop_tag,
            dirtag: p[:dirTag],
            arrival_time: Time.at(p[:epochTime].to_i / 1000),
            vehicle: p[:vehicle],
            block: p[:block],
            triptag: p[:tripTag]
          }
          puts params.inspect
          DB[:nextbus_predictions].insert params
        end
      end
    end

    def get_stop_tags(route_tag)
      DB["select stoptag from nextbus_route_configs where routetag = ?", route_tag].map {|s| s[:stoptag]}
    end
  end
end


if __FILE__ == $0
  #Nextbus.populate_route_list
  Nextbus.get_predictions("1")
end
