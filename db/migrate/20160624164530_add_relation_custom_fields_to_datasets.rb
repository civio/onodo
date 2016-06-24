class AddRelationCustomFieldsToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :relation_custom_fields, :hstore, array: true, default: []
  end
end
