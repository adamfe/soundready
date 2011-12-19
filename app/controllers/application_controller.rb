class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user 
    @current_user ||= User.find(session[:user_id]) if(session[:at] && session[:user_id])
  end

  def current_api
    @current_api ||= Rdio.new([MUSIC_CREDS['rdio']['consumer_key'], MUSIC_CREDS['rdio']['consumer_secret']], 
                              [current_user.token, current_user.token_secret])
  end

  def require_authentication
  	redirect_to login_path unless current_user
  end
end
