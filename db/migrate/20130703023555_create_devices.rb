class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :udid, :limit => 40
      t.string :product, :version, :secret_digest, :certificate_serial
      t.timestamps
    end
  end
end
