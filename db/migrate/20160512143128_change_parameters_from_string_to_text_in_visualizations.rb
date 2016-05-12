class ChangeParametersFromStringToTextInVisualizations < ActiveRecord::Migration
  def change
    change_column :visualizations, :parameters, :text
  end
end
