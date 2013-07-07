class Bundle < ActiveRecord::Base

  belongs_to :release
  belongs_to :repository # denormalized

  has_many :provisioned_devices, dependent: :destroy
  has_many :devices, through: :provisioned_devices

end
