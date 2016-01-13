class ApplicationController < ActionController::Base
  before_filter :authorize_miniprofiler
  protect_from_forgery
  include SessionsHelper

  def authorize_miniprofiler
    if not current_user.nil? and current_user.is_an_admin? and Rails.env.production?
      Rack::MiniProfiler.authorize_request
    end
  end
end
