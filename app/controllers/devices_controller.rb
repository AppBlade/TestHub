class DevicesController < ApplicationController

  skip_before_filter :verify_authenticity_token, only: :update

  def create
    @device = Device.create!
  end

  def update
    device = Device.find params[:id]
    if device.process_profile_server_response! request.raw_post
      render :nothing => true, :status => :ok
    else
      render :nothing => true, :status => :unauthorized
    end
  end

end
