class UserSession < ActiveRecord::Base
  
  include BCrypt

  belongs_to :user
  belongs_to :access_token

  before_create :generate_secret

  def secret
    @secret ||= Password.new secret_digest
  end

private

  def generate_secret
    @secret = SecureRandom.hex 32
    self.secret_digest = Password.create secret
  end

end
