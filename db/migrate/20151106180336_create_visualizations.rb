class CreateVisualizations < ActiveRecord::Migration
  def change
    create_table :visualizations do |t|
      t.text :name
      t.text :description
      t.boolean :published
      t.timestamps null: false
    end
  end
end
