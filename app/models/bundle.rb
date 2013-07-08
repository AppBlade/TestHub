class Bundle < ActiveRecord::Base

  belongs_to :release
  belongs_to :repository # denormalized

  has_many :provisioned_devices, dependent: :destroy
  has_many :devices, through: :provisioned_devices

  def install_errors(device)
		errors = []
    missing_capabilities     = capabilities.select{|k,v| v }.keys - Array(device.model.capabilities)
    missing_capabilities     = I18n.t missing_capabilities, scope: 'bundle.capabilities'
    forbidden_capabilities   = Array(device.model.capabilities) & capabilities.reject{|k,v| v }.keys
    forbidden_capabilities   = I18n.t forbidden_capabilities, scope: 'bundle.capabilities'
    capability_target_errors = (!armv6? || !armv7?) && minimum_os_version.to_f < 4.3 && capabilities.keys & %w(auto-focus-camera bluetooth-le camera-flash front-facing-camera gyroscope magnetometer opengles-2 video-camera) || []
    errors << 'expired'                 if expired?
    errors << 'armv7_thin_target_error' if armv7_thin_target_error?
    errors << 'required_capabilities'   if missing_capabilities.any?
    errors << 'forbidden_capabilities'  if forbidden_capabilities.any?
    errors << 'ipad_only'               if ipad_only? && device.model.family != :iPad
		errors << 'not_provisioned'         unless enterprise? || devices.include?(device)
    errors << 'minimum_os_not_met'      if device.operating_system < minimum_operating_system
    errors << 'capability_target_error' if capability_target_errors.any?
    I18n.t errors, scope: 'bundle.errors',
                   missing_capabilities: missing_capabilities.join(', '),
                   forbidden_capabilities: forbidden_capabilities.join(', '),
                   minimum_operating_system: minimum_operating_system,
                   capability_target_errors: capability_target_errors.join(', ')
  end

private

  def minimum_operating_system
    @minimum_operating_system ||= Ios::Version.new(minimum_os_version)
  end

  def armv7_thin_target_error?
    !armv6? && minimum_os_version.to_i < 4
  end

  def expired?
		expiration_date.nil? || expiration_date <= Time.now
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
