class Collaborator < ActiveRecord::Base

  belongs_to :user
  belongs_to :repository

end
