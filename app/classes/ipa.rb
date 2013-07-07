class Ipa

	attr_accessor :expiration_date, :capabilities, :bundle_identifier, :armv6, :armv7, :armv7s, :enterprise, :devices, :minimum_os_version, :bundle_display_name, :bundle_version, :ipad_only, :icon_files, :largest_icon, :errors

	def initialize(ipa_path)
    @errors = []
		@ipa_path = File.expand_path(ipa_path)
    @zipfile = Zip::ZipFile.open(ipa_path)

    unless @zipfile.dir.entries('/').include?('Payload')
      @errors << I18n.t('ipa.errors.no_payload')
      return false
    end

    zip_entries = @zipfile.dir.entries('/Payload').reject {|e| e =~ /^\./ }
    case zip_entries.count
    when 0
      @errors << I18n.t('ipa.errors.no_package')
      return false
    when 1
		  @package_name = zip_entries.first
    else
      @errors << I18n.t('ipa.errors.multiple_packages')
      return false
    end

    if @zipfile.file.exists?(path('embedded.mobileprovision'))

      mobile_provision = OpenSSL::PKCS7.new open('embedded.mobileprovision').read
      mobile_provision.verify nil, OpenSSL::X509::Store.new, nil, OpenSSL::PKCS7::NOVERIFY
      provisioning_plist_data = CFPropertyList::List.new(:data => mobile_provision.data).value

      @expiration_date = provisioning_plist_data.value['ExpirationDate'].value
      @enterprise      = !!provisioning_plist_data.value['ProvisionsAllDevices'].try(:value)
      @devices         = Array(provisioning_plist_data.value['ProvisionedDevices'].try(:value)).map(&:value)

    end

    @errors << I18n.t('ipa.errors.no_codesign', :package_name => @package_name) unless @zipfile.file.exists?(path('_CodeSignature/CodeResources'))

    if @zipfile.file.exists?(path('Info.plist'))

      info_plist_data = CFPropertyList::List.new(:data => open('Info.plist').read).value

      puts info_plist_data.inspect

      executable_path          = info_plist_data.value['CFBundleExecutable'].value
      @minimum_os_version      = info_plist_data.value['MinimumOSVersion'].value
      @bundle_display_name     = info_plist_data.value['CFBundleDisplayName'].value
      @bundle_identifier       = info_plist_data.value['CFBundleIdentifier'].value
      @bundle_version          = info_plist_data.value['CFBundleVersion'].value
      ui_device_family         = info_plist_data.value['UIDeviceFamily'].value
      @ipad_only               = ui_device_family.nil? || Array(ui_device_family).map(&:value).include?('1')
      ui_required_device_capabilities = info_plist_data.value['UIRequiredDeviceCapabilities']
      if ui_required_device_capabilities.present?
        if ui_required_device_capabilities.is_a? CFPropertyList::CFArray
          @capabilities = ui_required_device_capabilities.value.map(&:value).inject({}) do |hash, key| 
            hash.merge({key => true})
          end
        else
          @capabilities = ui_required_device_capabilities.value.inject({}) do |hash, (key, value)|
            hash.merge({key => value.value})
          end
        end
      end

      @armv6 = @armv7 = @armv7s = false

      tempfile = Tempfile.new(executable_path)
      @zipfile.extract(path(executable_path), tempfile.path) { true }
      `otool -hl "#{tempfile.path}"`.split("#{tempfile.path}").reject(&:blank?).each do |architecture_result|
      architecture = case architecture_result.match(/0xfeedface\s+12\s+(\d{1,2})/) && $1.to_i
        when 6
          @armv6 = true
        when 9
          @armv7 = true
        when 11
          @armv7s = true
        end
      end
      tempfile.unlink

      @icon_files = []
      @icon_files << info_plist_data.value['CFBundleIconFile'].try(:value)
      @icon_files << Array(info_plist_data.value['CFBundleIconFiles'].try(:value)).map(&:value)
      @icon_files << 'Icon.png' << 'Icon@2x.png' << 'Icon-72.png' << 'Icon-72@2x.png' << 'iTunesArtwork'
      @icon_files = @icon_files.flatten.compact.uniq.select{|f| @zipfile.file.exists? path(f) }

    else

      @errors << I18n.t('ipa.errors.missing_info_plist', :package_name => @package_name)

    end

  end

  def path(file)
    "Payload/#{@package_name}/#{file}"
  end

  def open(file)
    @zipfile.file.open(path(file))
  end
	
  def parsed_expiration_date
		expiration_date && DateTime.parse(expiration_date) || nil
  end

end
