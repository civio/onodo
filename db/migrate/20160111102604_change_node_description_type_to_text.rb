class ChangeNodeDescriptionTypeToText < ActiveRecord::Migration
  def change
    change_column :nodes, :description, :text
  end
end
