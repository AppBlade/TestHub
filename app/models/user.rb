class User < ActiveRecord::Base

  has_many :access_tokens, dependent: :destroy
  has_many :user_sessions, dependent: :destroy

  has_many :collaborations, class_name: 'Collaborator', dependent: :destroy
  has_many :repositories, through: :collaborations

  has_many :owned_repositories, as: :owner, dependent: :destroy

  def first_name
    name && name.split(' ').first || github_login
  end

end
