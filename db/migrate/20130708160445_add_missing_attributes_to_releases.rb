class AddMissingAttributesToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :tag_name, :string
    add_column :releases, :name, :string
    add_column :releases, :prerelease, :boolean, :default => false, :null => false
  end
end
