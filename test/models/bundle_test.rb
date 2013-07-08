require 'test_helper'

class BundleTest < ActiveSupport::TestCase

  fixtures :devices, :bundles

  test "that the valid IPA doesn't have install errors" do
    bundle = bundles(:valid_enterprise)
    assert bundle.install_errors(devices(:james_iphone_5)).empty?
    assert bundle.install_errors(devices(:james_ipad)).empty?
    assert bundle.install_errors(devices(:james_itouch)).empty?
    assert bundle.install_errors(devices(:james_macbook)).any?
  end

  test "an iOS7 beta device should be able to install an iOS 7 build" do
    bundle = bundles(:valid_enterprise)
    bundle.minimum_os_version = '7.0'
    assert bundle.install_errors(devices(:james_itouch)).empty?
  end

  test "that an expired IPA will have an error" do
    bundle = bundles(:valid_enterprise)
    bundle.expiration_date = 2.days.ago
    assert_equal bundle.install_errors(devices(:james_iphone_5)), ["provisioning profile has expired"]
  end

  test "that the minimum ios will trigger an error" do
    bundle = bundles(:valid_enterprise)
    bundle.minimum_os_version = '7.0'
    assert_equal bundle.install_errors(devices(:james_iphone_5)), ["requires iOS 7.0"]
  end

  test "that an ARMv7 target error will cause failure" do
    bundle = bundles(:valid_enterprise)
    bundle.minimum_os_version = '3.4'
    assert_equal bundle.install_errors(devices(:james_iphone_5)), ["ARMv7-thin builds require a minimum os target of 4.0 or higher"]
  end

  test "that required capabilities will cause failure" do
    bundle = bundles(:valid_enterprise)
    bundle.capabilities['auto-focus-camera'] = true
    bundle.capabilities['camera-flash'] = true
    assert_equal bundle.install_errors(devices(:james_itouch)), ["requires the presence of a camera with auto-focus capabilities, the presence of a camera flash"]
  end

  test "that forbidden capabilities will cause failure" do
    bundle = bundles(:valid_enterprise)
    bundle.capabilities['still-camera'] = false
    assert_equal bundle.install_errors(devices(:james_iphone_5)), ["forbids the presence of a camera"]
  end

  test "that iPad-only will cause failure" do
    bundle = bundles(:valid_enterprise)
    bundle.ipad_only = true
    assert_equal bundle.install_errors(devices(:james_iphone_5)), ["requires an iPad"]
  end

  test "capabilities target problems will cause failure" do
    bundle = bundles(:valid_enterprise)
    %w(auto-focus-camera bluetooth-le camera-flash front-facing-camera gyroscope magnetometer opengles-2 video-camera).each do |four_three_key|
      bundle.reload
      bundle.minimum_os_version = '4.2'
      bundle.capabilities[four_three_key] = true
      assert_equal bundle.install_errors(devices(:james_iphone_5)), ["setting #{four_three_key} in UIRequiredDeviceCapabilities requires either an ARMv6/7 fat binary or minimum os target of 4.3 or higher"]
    end
  end

end
