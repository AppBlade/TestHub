class AccessToken < ActiveRecord::Base

  def to_oauth2(client)
    @to_oauth2 ||= OAuth2::AccessToken.new client,
                                           decrypted_token, 
                                           options.merge({
                                             refresh_token: decrypted_refresh_token,
                                             expires_at: expires_at
                                           })
  end

  def decrypted_token
    ServerKey.private_decrypt(Base64.decode64(token))
  end

  def decrypted_refresh_token
    refresh_token && ServerKey.private_decrypt(Base64.decode64(refresh_token))
  end

end
