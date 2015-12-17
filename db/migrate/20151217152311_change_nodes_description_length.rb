class ChangeNodesDescriptionLength < ActiveRecord::Migration
  def change
    change_column :nodes, :description, :string, :limit => 255
  end
end
