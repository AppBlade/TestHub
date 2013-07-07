class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.integer :github_id, :repository_id
      t.string  :body, :github_etag
      t.timestamps
    end
    create_table :bundles do |t|
      t.integer  :github_id, :release_id, :repository_id
      t.string   :url, :minimum_os_version, :bundle_display_name, :bundle_version, :github_etag, :bundle_identifier
      t.boolean  :enterprise, :ipad_only, :armv6, :armv7, :armv7s
      t.string   :fatal_errors, :md5, array: true
      t.hstore   :capabilities
      t.datetime :expiration_date
      t.timestamps
    end
    create_table :provisioned_devices do |t|
      t.integer :bundle_id, :device_id
      t.timestamps
    end
  end
end
