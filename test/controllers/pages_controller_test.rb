require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end

  test 'index page' do
    get :index
    assert_response :success
  end

end
