require 'test_helper'

class DevicesControllerTest < ActionController::TestCase

  test 'mobileconfig phase1' do
    
    post :create, format: 'mobileconfig'
    assert_response :success

    device_id = @response.body =~ /http:\/\/test\.host\/devices\/(\d+)/ && $1
    assert_not_nil device_id

    # Need to work on faking the store
    # @request.env['RAW_POST_DATA'] = 'asfd'
    # post :update, id: Device.last.id
    # assert_response :success
  end

end
