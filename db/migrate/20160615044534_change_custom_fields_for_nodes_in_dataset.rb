class ChangeCustomFieldsForNodesInDataset < ActiveRecord::Migration
  include TypeUtil

  def up
    add_column :datasets, :node_custom_fields, :hstore, array: true, default: []

    Dataset.find_each do |dataset|
      node_custom_fields = dataset.custom_fields.map{ |cf| { "name" => cf, "type" => type_for(dataset.nodes.map{ |n| n.custom_fields[cf] }) } }
      dataset.update_attribute(:node_custom_fields, node_custom_fields)
    end

    remove_column :datasets, :custom_fields
  end

  def down
    add_column :datasets, :custom_fields, :text, array: true, default: []

    Dataset.find_each do |dataset|
      custom_fields = dataset.node_custom_fields.map{ |cf| cf["name"] }
      dataset.update_attribute(:custom_fields, custom_fields)
    end

    remove_column :datasets, :node_custom_fields
  end
end
