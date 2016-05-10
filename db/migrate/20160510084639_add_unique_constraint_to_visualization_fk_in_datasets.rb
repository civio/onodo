class AddUniqueConstraintToVisualizationFkInDatasets < ActiveRecord::Migration
  def up
    remove_index :datasets, :visualization_id
    add_index :datasets, :visualization_id, unique: true
  end

  def down
    remove_index :datasets, :visualization_id
    add_index :datasets, :visualization_id
  end
end
