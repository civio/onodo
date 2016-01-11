class ChangeVisualizationDescriptionTypeToText < ActiveRecord::Migration
  def change
    change_column :visualizations, :description, :text
  end
end
