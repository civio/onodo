class AddCustomFieldsToRelations < ActiveRecord::Migration
  def change
    add_column :relations, :custom_fields, :hstore

    add_index :relations, :custom_fields, using: :gist
  end
end
