class AlertsController < ApplicationController
  layout 'mobile'

  def index
    @alerts = DB["select * from t_alerts order by pubdate desc limit 40"].all
  end


end
