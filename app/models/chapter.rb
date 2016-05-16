class Chapter < ActiveRecord::Base
  belongs_to :story
  has_and_belongs_to_many :nodes
  has_and_belongs_to_many :relations

  validates :name, presence: true
end
