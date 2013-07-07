class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.integer :github_id, :owner_id
      t.string  :github_etag, :name, :full_name, :description
      t.timestamps
    end
    create_table :collaborators do |t|
      t.integer :user_id, :repository_id
    end
  end
end
