class CreateUserSessions < ActiveRecord::Migration
  def change
    create_table :user_sessions do |t|
      t.integer :user_id, :access_token_id
      t.string  :secret_digest
      t.timestamps
    end
  end
end
