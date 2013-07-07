class User < ActiveRecord::Base

  has_one :access_token, dependent: :destroy

  

end
