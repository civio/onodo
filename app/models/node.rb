class Node < ActiveRecord::Base
  belongs_to :dataset
  has_many :relations_as_source, foreign_key: :source_id, class_name: Relation, inverse_of: :source
  has_many :relations_as_target, foreign_key: :target_id, class_name: Relation, inverse_of: :target

  store_accessor :custom_fields
  mount_uploader :image, NodeImageUploader

  # Returns all the relations a node is involved in.
  #   This is cleaner than prefetching relations_as_source, adding to relations_as_source...
  def relations
    Relation.where('source_id = ? or target_id = ?', self, self)
            .includes(:relation_type, :source, :target)
  end
end
