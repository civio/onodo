class ChangeRelationsType < ActiveRecord::Migration
  def change
    rename_column :relations, :type, :relation_type
  end
end
