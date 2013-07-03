ServerKey    = OpenSSL::PKey::RSA.new          File.read(File.join(Rails.root, 'lib/ssl/server.key')), ENV['SERVER_PHRASE']
ServerCert   = OpenSSL::X509::Certificate.new  File.read(File.join(Rails.root, 'lib/ssl/server.crt'))
ServerCA     = OpenSSL::X509::Certificate.new  File.read(File.join(Rails.root, 'lib/ssl/ca.crt'))
ServerChain  = [ServerCA]

SCEPKey   = OpenSSL::PKey::RSA.new          File.read(File.join(Rails.root, 'lib/ssl/scep.key')), ENV['SCEP_PHRASE']
SCEPCert  = OpenSSL::X509::Certificate.new  File.read(File.join(Rails.root, 'lib/ssl/scep.crt'))
SCEPStore = OpenSSL::X509::Store.new
SCEPStore.add_cert SCEPCert

ProfileServiceKey   = OpenSSL::PKey::RSA.new          File.read(File.join(Rails.root, 'lib/ssl/profile_service.key')), ENV['PROFILE_SERVICE_PHRASE']
ProfileServiceCert  = OpenSSL::X509::Certificate.new  File.read(File.join(Rails.root, 'lib/ssl/profile_service.crt'))
ProfileServiceStore = OpenSSL::X509::Store.new
ProfileServiceStore.add_cert ProfileServiceCert
