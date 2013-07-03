module DevicesHelper

  def sign_contents(&block)
		OpenSSL::PKCS7::sign(ServerCert, ServerKey, capture(&block).strip, ServerChain, OpenSSL::PKCS7::BINARY).to_der.html_safe
  end

end
