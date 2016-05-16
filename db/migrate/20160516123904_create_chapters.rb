class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.string :name, null: false
      t.text :description
      t.integer :number
      t.references :story, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
