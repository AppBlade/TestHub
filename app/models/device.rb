class Device < ActiveRecord::Base

  include BCrypt

  before_create :generate_secret

  has_many :provisioned_devices, dependent: :destroy
  has_many :bundles, through: :provisioned_devices

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

  def model
    @device_model ||= Product.new product, serial
  end

  def operating_system
    @operating_system ||= Ios::Version.new version
  end

private

  def generate_secret
    @secret = SecureRandom.hex 32
    self.secret_digest = Password.create secret
  end

end
