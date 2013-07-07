class ProvisionedDevice < ActiveRecord::Base

  belongs_to :bundle
  belongs_to :device

end
