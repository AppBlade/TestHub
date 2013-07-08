class Bundle < ActiveRecord::Base

  belongs_to :release
  belongs_to :repository # denormalized

  has_many :provisioned_devices, dependent: :destroy
  has_many :devices, through: :provisioned_devices

  def install_errors(device)
		errors = []
    # return ['Application has expired'] if expired?
    # return ['Application is broken'] if needs_some_serious_love?
    # if ipad_only? && !device.device_model.family != :iPad
    #   errors << "Requires #{supported_devices.join(', ')} or newer model"
    #   errors << "running iOS #{minimum_os_version} or higher" if minimum_os_version
    # end
    missing_capabilities   = capabilities.select{|k,v| v }.keys - Array(device.model.capabilities)
    forbidden_capabilities = Array(device.model.capabilities) & capabilities.reject{|k,v| v }.keys
    errors << "requires #{missing_capabilities.join(', ')} capabilities"  if missing_capabilities.any?
    errors << "forbids #{forbidden_capabilities.join(', ')} capabilities" if forbidden_capabilities.any?
    errors << 'requires an iPad' if ipad_only? && device.model.family != :iPad
		errors << 'is not provisioned' unless enterprise? || devices.include?(device)
    errors << "requires iOS #{minimum_operating_system}" if device.operating_system < minimum_operating_system
    errors
  end

  def minimum_operating_system
    @minimum_operating_system ||= Ios::Version.new(nil, minimum_os_version)
  end

  def expired?
		!!expiration_date && expiration_date <= Time.now
	end

  def arm_flag_issue?
		armv7_thin? && minimum_os_version.to_i < 4
	end

  def armv7_thin?
    !armv7s? && armv7? && !armv6?
  end

  def armv7s_thin?
    armv7s? && !armv7? && !armv6?
  end

end
