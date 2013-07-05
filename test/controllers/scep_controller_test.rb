require 'test_helper'

class ScepControllerTest < ActionController::TestCase

  test 'CACaps' do
    get :get_ca_caps
    assert_response :success
    assert_equal @response.body.split, %w(POSTPKIOperation SHA-1)
  end

  test 'CACert' do
    get :get_ca_cert
    assert_response :success
    assert_equal @response.body, SCEPCert.to_der
  end

end

