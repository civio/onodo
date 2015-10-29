class Node < ActiveRecord::Base
  has_many :relations_as_source, foreign_key: :source_id, class_name: Relation, inverse_of: :source
  has_many :relations_as_target, foreign_key: :target_id, class_name: Relation, inverse_of: :target

  validates :name, presence: true, uniqueness: true
  validates :description, length: { maximum: 90 }
end
