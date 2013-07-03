class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :exception

  helper_method :current_device

private

  def current_device
    @current_device ||= Device.where(:certificate_serial => ssl_client_serial).first if ssl_client_serial
  end

  def ssl_client_serial
    request.headers['HTTP_SSL_CLIENT_SERIAL']
  end

end
