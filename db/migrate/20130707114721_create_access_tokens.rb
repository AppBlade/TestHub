class CreateAccessTokens < ActiveRecord::Migration
  def change
    create_table :access_tokens do |t|
      t.string   :token, :refresh_token
      t.datetime :expires_at
      t.hstore   :options
      t.timestamps
    end
  end
end
