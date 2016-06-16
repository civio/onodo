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

  def visualization
    dataset.visualization if dataset
  end

  def stories
    dataset.visualization.stories if dataset && dataset.visualization
  end

  def from
    read_attribute(:from).strftime('%d/%m/%Y') unless read_attribute(:from).nil?
  end

  alias_method :at, :from

  def to
    read_attribute(:to).strftime('%d/%m/%Y') unless read_attribute(:to).nil?
  end

end
