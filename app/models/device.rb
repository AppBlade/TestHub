class Device < ActiveRecord::Base

  include BCrypt

  before_create :generate_secret

  def secret
    @secret ||= Password.new secret_digest
  end

  def update_profile_service_attributes!(response_attributes)
    self.product = response_attributes.value['PRODUCT'].value
    self.udid    = response_attributes.value['UDID'].value
    self.version = response_attributes.value['VERSION'].value
    self.serial  = response_attributes.value['SERIAL'].value
    generate_secret
    save
  end

private

  def generate_secret
    @secret = SecureRandom.hex 32
    self.secret_digest = Password.create secret
  end

end
