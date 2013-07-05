require 'openssl'
require 'digest/md5'
require 'tmpdir'
require 'zip/zipfilesystem'

class Ipa

	attr_accessor :expiration_date, :enterprise, :devices, :minimum_os_version, :bundle_display_name, :bundle_version, :ipad_only, :icon_files, :largest_icon, :errors

	def initialize(ipa_path)
    @errors = []
		@ipa_path = File.expand_path(ipa_path)
    @zipfile = Zip::ZipFile.open(ipa_path)

    unless @zipfile.dir.entries('/').include?('Payload')
      @errors << '"/Payload" does not exist'
      return false
    end

    zip_entries = @zipfile.dir.entries('/Payload').reject {|e| e =~ /^\./ }
    case zip_entries.count
    when 0
      @errors << '"/Payload" does not contain a package'
      return false
    when 1
		  @package_name = zip_entries.first
    else
      @errors << 'multiple payloads found'
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

    @errors << 'has not been code-signed' unless @zipfile.file.exists?(path('_CodeSignature/CodeResources'))

    if @zipfile.file.exists?(path('Info.plist'))

      info_plist_data = CFPropertyList::List.new(:data => open('Info.plist').read).value

      @minimum_os_version      = info_plist_data.value['MinimumOSVersion'].value
      @bundle_display_name     = info_plist_data.value['CFBundleDisplayName'].value
      @bundle_version          = info_plist_data.value['CFBundleVersion'].value
      @ipad_only               = Array(info_plist_data.value['UIDeviceFamily'].value).map(&:value).include?('1')

      @icon_files = []
      @icon_files << info_plist_data.value['CFBundleIconFile'].try(:value)
      @icon_files << Array(info_plist_data.value['CFBundleIconFiles'].try(:value)).map(&:value)
      @icon_files << 'Icon.png' << 'Icon@2x.png' << 'Icon-72.png' << 'Icon-72@2x.png' << 'iTunesArtwork'
      @icon_files = @icon_files.flatten.compact.uniq.select{|f| @zipfile.file.exists? path(f) }

    else

      @errors << 'is missing Info.plist'

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
