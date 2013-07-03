module DevicesHelper

  def sign_contents(&block)
		OpenSSL::PKCS7::sign(SSLCert, RSAKey, capture(&block).strip, SSLChain, OpenSSL::PKCS7::BINARY).to_der.html_safe
  end

end
