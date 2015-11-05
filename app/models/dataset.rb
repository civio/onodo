class Dataset < ActiveRecord::Base
  #belongs_to :author, foreign_key: :author_id, class_name: User
  has_many :nodes
  has_many :relations
end
