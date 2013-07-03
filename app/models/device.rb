class Device < ActiveRecord::Base

  include BCrypt

  before_create :generate_secret

  def secret
    @secret ||= Password.new secret_digest
  end

  def update_profile_service_attributes!(response_attributes)
    self.product = response_attributes['PRODUCT']
    self.udid    = response_attributes['UDID']
    self.version = response_attributes['VERSION']
    generate_secret
    save
  end

private

  def generate_secret
    @secret = SecureRandom.hex 32
    self.secret_digest = Password.create secret
  end

end
