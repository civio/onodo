class AddImageToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :image, :string
  end
end
