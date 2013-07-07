class Repository < ActiveRecord::Base

  belongs_to :owner, class_name: 'User'

  has_many :collaborators, dependent: :destroy
  has_many :users, through: :collaborators

end
