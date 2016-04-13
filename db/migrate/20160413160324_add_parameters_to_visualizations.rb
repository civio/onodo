class AddParametersToVisualizations < ActiveRecord::Migration
  def change
    add_column :visualizations, :parameters, :string, :limit => 255
  end
end
