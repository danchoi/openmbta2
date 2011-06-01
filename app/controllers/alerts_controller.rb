class AlertsController < ApplicationController
  layout 'mobile'

  def index
    @alerts = DB["select * from t_alerts order by pubdate desc limit 40"].all
  end

  def show
    @alert = DB[:t_alerts].filter(:guid => params[:guid]).first
    render :layout => 'iphone_layout'
  end

end
