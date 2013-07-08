class Bundle < ActiveRecord::Base

  belongs_to :release
  belongs_to :repository # denormalized

  has_many :provisioned_devices, dependent: :destroy
  has_many :devices, through: :provisioned_devices

  def install_errors(device)
		errors = []
    missing_capabilities   = capabilities.select{|k,v| v }.keys - Array(device.model.capabilities)
    missing_capabilities.map! {|c| I18n.t("bundle.capabilities.#{c}")}
    forbidden_capabilities = Array(device.model.capabilities) & capabilities.reject{|k,v| v }.keys
    forbidden_capabilities.map! {|c| I18n.t("bundle.capabilities.#{c}")}
    errors << I18n.t('bundle.errors.armv7_thin_minimum_os_issue') if armv7_thin_minimum_os_issue?
    errors << I18n.t('bundle.errors.required_capabilities', missing_capabilities: missing_capabilities.join(', ')) if missing_capabilities.any?
    errors << I18n.t('bundle.errors.forbidden_capabilities', forbidden_capabilities: forbidden_capabilities.join(', ')) if forbidden_capabilities.any?
    errors << I18n.t('bundle.errors.ipad_only') if ipad_only? && device.model.family != :iPad
		errors << I18n.t('bundle.errors.not_provisioned') unless enterprise? || devices.include?(device)
    errors << I18n.t('bundle.errors.minimum_os_not_met', minimum_operating_system: minimum_operating_system) if device.operating_system < minimum_operating_system
    errors
  end

  def minimum_operating_system
    @minimum_operating_system ||= Ios::Version.new(nil, minimum_os_version)
  end

  def armv7_thin_minimum_os_issue?
    armv7_thin? && minimum_os_version.to_i < 4
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
