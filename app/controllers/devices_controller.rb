class DevicesController < ApplicationController

  skip_before_filter :verify_authenticity_token, only: :update

  def create
    @device = Device.create!
  end

  def update
    profile_service_response = OpenSSL::PKCS7.new request.raw_post
    profile_service_response.verify [], AppleDeviceX509Store, nil, OpenSSL::PKCS7::NOVERIFY
    profile_service_attributes = Plist::parse_xml profile_service_response.data
    @device = Device.where(:udid => profile_service_attributes['UDID']).first
    @device ||= Device.find params[:id]
    if @device.update_profile_service_attributes! profile_service_attributes
      if profile_service_attributes['CHALLENGE']
        
        key = OpenSSL::PKey::RSA.new 1024

        cert = OpenSSL::X509::Certificate.new
        cert.version = 2
        cert.serial = 1
        cert.not_before = Time.now
        cert.not_after = Time.now + 10.minutes

        cert.public_key = key.public_key
        cert.subject = OpenSSL::X509::Name.parse "CN=Device Registration Phase 2"
        cert.issuer = cert.subject
        cert.sign key, OpenSSL::Digest::SHA1.new

        @password = SecureRandom.hex 32
        @uuid = SecureRandom.uuid
        @p12 = OpenSSL::PKCS12.create @password, @uuid, key, cert

      else
        render 'scep/new'
      end
    else
      render :nothing => true, :status => :unauthorized
    end
  end

end
