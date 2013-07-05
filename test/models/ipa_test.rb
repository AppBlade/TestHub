require 'test_helper'

class IpaTest < ActiveSupport::TestCase

  test 'JBoss Toy Store' do
    ipa = Ipa.new File.join(Rails.root, 'test/bundles/JBossToyStore.ipa')
    assert_equal ipa.expiration_date, '2013-06-12 16:11:35 -0400'
    assert       ipa.enterprise
    assert_equal ipa.devices, []
    assert_equal ipa.minimum_os_version, '3.0'
    assert_equal ipa.bundle_display_name, 'JBoss Toy Store'
    assert_equal ipa.bundle_version, '1.1'
    assert       !ipa.ipad_only
    assert_equal ipa.icon_files, %w(icon.png Icon-72.png)
    assert_equal ipa.errors, []
  end

  test 'Test IPA' do
    ipa = Ipa.new File.join(Rails.root, 'test/bundles/test.ipa')
    assert_equal ipa.expiration_date, '2012-02-28 22:01:10 -0500'
    assert       !ipa.enterprise
    assert_equal ipa.devices, %w(70deb83cb217513954c0311b27065be615e5446c 43d6a6791c427a4f80ae75998e7b5519c3b60a4a)
    assert_equal ipa.minimum_os_version, '4.2'
    assert_equal ipa.bundle_display_name, 'Test App'
    assert_equal ipa.bundle_version, '1.0'
    assert       !ipa.ipad_only
    assert_equal ipa.icon_files, %w(Icon.png)
    assert_equal ipa.errors, []
  end

  test 'No payload' do
    ipa = Ipa.new File.join(Rails.root, 'test/bundles/noPayload.ipa')
    assert_equal ipa.errors, ['"/Payload" does not exist']
  end

  test 'No packages' do
    ipa = Ipa.new File.join(Rails.root, 'test/bundles/noPackages.ipa')
    assert_equal ipa.errors, ['"/Payload" does not contain a package']
  end

  test 'Two packages' do
    ipa = Ipa.new File.join(Rails.root, 'test/bundles/twoPackages.ipa')
    assert_equal ipa.errors, ['"/Payload" contains multiple packages']
  end

end
