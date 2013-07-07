class User < ActiveRecord::Base

  has_many :access_tokens, dependent: :destroy
  has_many :user_sessions, dependent: :destroy 

  def first_name
    name && name.split(' ').first || github_login
  end

end
