class MainController < ApplicationController
  layout 'mobile'

  def index
    @modes = ["Bus", "Commuter Rail", "Subway", "Boat"] 
  end

end
