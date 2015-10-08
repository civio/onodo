class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :name
      t.string :description
      t.boolean :visible

      t.timestamps null: false
    end
  end
end
