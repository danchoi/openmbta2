require 'json'
require 'transit_routes'
require 'transit_trips'
require 'direction'
require 'merge_realtime'
require 'merge_realtime_commuter_rail'
require 'rexml/document'
require 'nextbus_feeds'
require 'subway_feed'

module OpenMBTA
  class InvalidDirection < StandardError; end
end
