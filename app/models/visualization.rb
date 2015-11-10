class Visualization < ActiveRecord::Base
  has_one :dataset

  validates :name, presence: true, uniqueness: true
end
