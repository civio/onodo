class ChangeCustomFieldsInNodes < ActiveRecord::Migration
  def up
    enable_extension 'hstore'
    add_column :nodes, :custom_fields, :hstore

    Node.find_each do |node|
      custom_fields = nil
      suppress(JSON::ParserError) do
        custom_fields = JSON.parse node.custom_field.to_s.gsub('=>', ':')
      end
      node.update_attribute(:custom_fields, custom_fields)
    end

    remove_column :nodes, :custom_field

    add_index :nodes, :custom_fields, using: :gist
  end

  def down
    add_column :nodes, :custom_field, :string

    Node.find_each do |node|
      node.update_attribute(:custom_field, node.custom_fields.to_s)
    end

    remove_column :nodes, :custom_fields
    disable_extension 'hstore'
  end
end
