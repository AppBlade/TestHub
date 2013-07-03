class Device < ActiveRecord::Base

  include BCrypt

  before_create :generate_secret

  def secret
    @secret ||= Password.new secret_digest
  end

  def process_profile_server_response!(raw_profile_service_response)
    profile_service_response = OpenSSL::PKCS7.new raw_profile_service_response
    device_certificate = profile_service_response.certificates.first
    return false unless AppleDeviceX509Store.verify device_certificate 
    return false unless profile_service_response.verify [device_certificate], AppleDeviceX509Store, nil, OpenSSL::PKCS7::NOVERIFY
    response_attributes = Plist::parse_xml profile_service_response.data
    return false unless secret == response_attributes['CHALLENGE']
    device = Device.where(:udid => response_attributes['UDID']).first
    device ||= self
    device.product = response_attributes['PRODUCT']
    device.udid    = response_attributes['UDID']
    device.version = response_attributes['VERSION']
    device.certificate_serial = profile_service_response.signers.first.serial.to_s(16)
    device.save
  end

private

  def generate_secret
    @secret = SecureRandom.hex 32
    self.secret_digest = Password.create secret
  end

end
