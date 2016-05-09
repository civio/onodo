class ChangeCustomFieldsInNodes < ActiveRecord::Migration
  def change
    enable_extension 'hstore'
    rename_column :nodes, :custom_field, :custom_fields
    change_column :nodes, :custom_fields, 'hstore USING CAST(custom_fields AS hstore);'

    add_index :nodes, :custom_fields, using: :gist
  end
end
