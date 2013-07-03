require 'test_helper'

class DeviceTest < ActiveSupport::TestCase

  test 'secret works' do
    device = Device.create
    saved_secret = device.secret
    assert BCrypt::Password.new(device.secret_digest) == saved_secret
  end

end
