class PagesController < ApplicationController

  def index
    puts request.headers['HTTP_SSL_CLIENT_SERIAL']
  end

end
