class HomeController < ApplicationController

  def index
    Rails.logger.warn("GEM_HOME is #{ENV['GEM_HOME']}")
  end

  def mobile_howto
    @transport_type = "Bus"
  end

end

