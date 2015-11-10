class Dataset < ActiveRecord::Base
  #belongs_to :author, foreign_key: :author_id, class_name: User
  belongs_to :visualization
  has_many :nodes
  has_many :relations

  validates :visualization, presence: true
end
