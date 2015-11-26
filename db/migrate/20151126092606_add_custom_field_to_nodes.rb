class AddCustomFieldToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :custom_field, :string
  end
end
