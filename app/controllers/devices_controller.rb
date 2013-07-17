class DevicesController < ApplicationController

  skip_before_filter :verify_authenticity_token, only: :update

  def create
    @device = Device.create!
    send_data signed_payload(:profile_service).to_der, :content_type => :mobileconfig
  end

  def update
    profile_service_response = OpenSSL::PKCS7.new request.raw_post
    profile_service_response.verify profile_service_response.certificates, AppleDeviceX509Store, nil, OpenSSL::PKCS7::NOINTERN | OpenSSL::PKCS7::NOCHAIN
    profile_service_attributes = CFPropertyList::List.new(:data => profile_service_response.data).value
    @device = Device.where(:id => params[:id]).first
    existing_device = Device.where(:udid => profile_service_attributes.value['UDID'].value).first
    if existing_device && existing_device != @device
      @device.try :destroy
      @device = existing_device
    end
    @device.update_profile_service_attributes! profile_service_attributes

    if profile_service_attributes.value['CHALLENGE']
      send_data signed_payload(:profile_service_response).to_der, :content_type => :mobileconfig
    else
      send_data signed_payload(:scep).to_der, :content_type => :mobileconfig
    end
  end

private

  def signed_payload(payload)
		OpenSSL::PKCS7::sign ServerCert,
                         ServerKey,
                         CFPropertyList.xml_parser_interface.new.to_str(:root => CFPropertyList.guess(self.send("#{payload}_payload"))),
                         ServerChain,
                         OpenSSL::PKCS7::BINARY
  end

  def scep_payload
    {
      PayloadContent: [{
        PayloadContent: {
          Challenge: [@device.id, @device.secret].join(':'),
          Keysize: 1024,
          Subject: [
            [['CN', t('devices.scep.cn')]]
          ],
          URL: scep_url
        },
        PayloadVersion: 1,
        PayloadUUID: SecureRandom.uuid,
        PayloadIdentifier: 'com.testhub.registration.phase-3.scep',
        PayloadType: 'com.apple.security.scep'
      }],
      PayloadDisplayName: t('devices.new.display_name'),
      PayloadOrganization: t('devices.new.organization'),
      PayloadVersion: 1,
      PayloadUUID: SecureRandom.uuid,
      PayloadIdentifier: 'com.testhub.registration.phase-3',
      PayloadType: 'Configuration'
    }
  end

  def profile_service_payload
    {
      PayloadContent: {
        URL: device_url(@device),
        DeviceAttributes: %w(UDID VERSION PRODUCT SERIAL),
        Challenge: @device.secret
      },
      PayloadOrganization: t('devices.new.organization'),
      PayloadDisplayName: t('devices.new.display_name'),
      PayloadVersion: 1,
      PayloadUUID: SecureRandom.uuid,
      PayloadIdentifier: 'com.testhub.registration',
      PayloadDescription: t('devices.new.description'),
      PayloadType: 'Profile Service'
    }
  end

  def profile_service_response_payload
    key = OpenSSL::PKey::RSA.new 1024

    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = Random.rand(2**(159))
    cert.not_before = Time.now
    cert.not_after = Time.now + 10.minutes
    cert.public_key = key.public_key
    cert.subject = OpenSSL::X509::Name.parse "CN=Device Registration Phase 2"
    cert.issuer = ProfileServiceCert.subject
    cert.sign ProfileServiceKey, OpenSSL::Digest::SHA1.new

    password = SecureRandom.hex 32
    uuid = SecureRandom.uuid
    p12 = OpenSSL::PKCS12.create password, uuid, key, cert

    {
      PayloadContent: [{
        Password: password,
        PayloadContent: StringIO.new(p12.to_der),
        PayloadIdentifier: 'com.testhub.registration.phase-2.credentials',
        PayloadType: 'com.apple.security.pkcs12',
        PayloadUUID: uuid,
        PayloadVersion: 1
      }],
      PayloadDisplayName: t('devices.new.display_name'),
      PayloadVersion: 1,
      PayloadUUID: SecureRandom.uuid,
      PayloadIdentifier: 'com.testhub.registration.phase-2',
      PayloadType: 'Configuration'
    }
  end

end
