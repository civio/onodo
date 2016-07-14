class Dataset < ActiveRecord::Base
  #belongs_to :author, foreign_key: :author_id, class_name: User
  belongs_to :visualization
  has_many :nodes, dependent: :destroy, autosave: true
  has_many :relations, dependent: :destroy, autosave: true

  validates :visualization, presence: true, uniqueness: true
end
