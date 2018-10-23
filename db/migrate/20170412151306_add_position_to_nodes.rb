class AddPositionToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :posx, :integer
    add_column :nodes, :posy, :integer
  end
end
