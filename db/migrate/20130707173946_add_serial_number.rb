class AddSerialNumber < ActiveRecord::Migration
  def change
    add_column :devices, :serial, :string
  end
end
