RSAKey    = OpenSSL::PKey::RSA.new File.read("#{Rails.root}/lib/ssl/ssl.key"), ENV['RSA_PASS']
SSLCert   = OpenSSL::X509::Certificate.new File.read("#{Rails.root}/lib/ssl/ssl.crt")
SSLChain  = [OpenSSL::X509::Certificate.new(File.read("#{Rails.root}/lib/ssl/ssl_bundle.crt"))]
SCEPKey   = OpenSSL::PKey::RSA.new File.read("#{Rails.root}/lib/ssl/scep.key")
SCEPCert  = OpenSSL::X509::Certificate.new File.read("#{Rails.root}/lib/ssl/scep.crt")
SCEPStore = OpenSSL::X509::Store.new
SCEPStore.add_cert SCEPCert
