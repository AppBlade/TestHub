class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :exception

  before_filter :find_current_user_session

  helper_method :current_device, :current_user_session, :current_user, :remember_current_user_session

private

  def current_device
    @current_device ||= Device.where(:certificate_serial => ssl_client_serial.downcase).first if ssl_client_serial
  end

  def current_user
    @current_user ||= current_user_session.try(:user)
  end

  def ssl_client_serial
    @ssl_client_serial ||= request.headers['HTTP_SSL_CLIENT_SERIAL']
  end

  def find_current_user_session
    if session[:user_session_id]
      @current_user_session = UserSession.where(id: session[:user_session_id]).first
      @current_user_session = nil unless @current_user_session.try(:secret) == session[:user_session_secret]
    end
  end

  def remember_current_user_session
    session[:user_session_id]     = @current_user_session.id
    session[:user_session_secret] = @current_user_session.secret
  end

  def current_user_session
    @current_user_session
  end

end
