require 'test_helper'

class ProductTest < ActiveSupport::TestCase

  test 'known devices' do
    assert_equal devices(:james_iphone_5).model.to_s, 'iPhone 5'
    assert_equal devices(:james_ipad).model.to_s,     'iPad 3'
    assert_equal devices(:james_itouch).model.to_s,   'iPod Touch 5'
    assert_equal devices(:james_macbook).model.to_s,  'MacBook Pro' 
  end

end
