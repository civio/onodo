class Relation < ActiveRecord::Base
  belongs_to :dataset
  belongs_to :source, 
              foreign_key: :source_id, 
              class_name: Node, 
              inverse_of: :relations_as_source, 
              touch: true
  belongs_to :target, 
              foreign_key: :target_id, 
              class_name: Node, 
              inverse_of: :relations_as_target, 
              touch: true
end
