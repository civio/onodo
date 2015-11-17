class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.text :name
      t.integer :author_id, references: :users
      t.timestamps null: false
    end
  end
end
