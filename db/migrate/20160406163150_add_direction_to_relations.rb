class AddDirectionToRelations < ActiveRecord::Migration
  def change
    add_column :relations, :direction, :boolean, :default => true
  end
end
