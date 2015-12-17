class ChangeVisualizationDescriptionLength < ActiveRecord::Migration
  def change
    change_column :visualizations, :description,  :string, :limit => 255
  end
end
