class Release < ActiveRecord::Base

  belongs_to :repository

  has_many :bundles, dependent: :destroy

end
