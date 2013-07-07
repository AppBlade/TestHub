class TokenDigest < ActiveRecord::Migration
  def change
    add_column :access_tokens, :token_digest, :string, :limit => 40
    AccessToken.all.each do |access_token|
      access_token.token_digest = Digest::SHA1.hexdigest(access_token.decrypted_token)
      access_token.save
    end
  end
end
