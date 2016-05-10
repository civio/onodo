class Dataset < ActiveRecord::Base
  #belongs_to :author, foreign_key: :author_id, class_name: User
  belongs_to :visualization
  has_many :nodes, dependent: :destroy
  has_many :relations, dependent: :destroy

  validates :visualization, presence: true, uniqueness: true
end
