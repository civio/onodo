class AddCustomFieldsToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :custom_fields, :text, array: true, default: []
  end
end
