class AccessToken < ActiveRecord::Base

  belongs_to :user

  validate :token, presence: true

  def to_oauth2(client)
    @to_oauth2 ||= OAuth2::AccessToken.new client,
                                           decrypted_token, 
                                           options.merge({
                                             refresh_token: decrypted_refresh_token,
                                             expires_at: expires_at
                                           })
  end

  def decrypted_token
    DatabaseKey.private_decrypt token
  end

  def decrypted_refresh_token
    refresh_token && DatabaseKey.private_decrypt(refresh_token)
  end

end
