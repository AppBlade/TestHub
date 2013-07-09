require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test 'first name' do
    user = User.new name: 'James Daniels'
    assert_equal user.first_name, 'James'
  end

end
