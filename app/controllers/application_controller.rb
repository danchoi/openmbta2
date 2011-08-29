class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :log_user_agent

  layout 'application'

  def log_user_agent
    logger.info("USER AGENT: #{request.env["HTTP_USER_AGENT"]}")
  end
end
