class AddTypeToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :node_type, :string
  end
end
