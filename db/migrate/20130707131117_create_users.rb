class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :github_id
      t.string  :github_login, :name, :email, :avatar_url, :github_etag
      t.timestamps
    end
    add_column :access_tokens, :user_id, :integer
  end
end
